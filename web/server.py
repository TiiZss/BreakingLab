#!/usr/bin/env python3
"""Panel local de BreakingLab. Solo escucha en 127.0.0.1."""

import json
import re
import shutil
import subprocess
import sys
from datetime import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent
WEB = ROOT / "web"
HOST = "127.0.0.1"
PORT = 8765
CONF_LINE = re.compile(r'^DOCKER_PROJECTS\["([^"]+)"\]="(.*)"\s*$')
LAB_NAME = re.compile(r"^[A-Za-z0-9_-]+$")
HOST_PORT = re.compile(r"0\.0\.0\.0:(\d+)->")
URL_HOST = re.compile(r"^https?://[^/]*(.*)$")
ANSI = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")


def read_labs():
    labs = []
    folder = ROOT / "config" / "projects.d"
    for path in sorted(folder.glob("docker_*.conf")):
        line = path.read_text(encoding="utf-8", errors="replace").splitlines()
        if not line:
            continue
        match = CONF_LINE.match(line[0].strip())
        if not match:
            continue
        name, raw = match.group(1), match.group(2)
        parts = raw.split("|")
        while len(parts) < 6:
            parts.append("")
        labs.append(
            {
                "name": name,
                "ip": parts[1],
                "port": parts[2],
                "desc": parts[3],
                "url": parts[4],
            }
        )
    return labs


def docker_rows():
    try:
        out = subprocess.run(
            ["docker", "ps", "--format", "{{.Names}}\t{{.Label \"breakinglab.lab\"}}\t{{.Ports}}"],
            check=False,
            capture_output=True,
            text=True,
            timeout=20,
        )
    except (OSError, subprocess.TimeoutExpired):
        return []
    rows = []
    for line in out.stdout.splitlines():
        name, label, ports = (line.split("\t") + ["", "", ""])[:3]
        rows.append((name, label, ports))
    return rows


def lab_state(lab, rows):
    key = lab["name"]
    running = False
    public = False
    ports_found = []
    seen = set()
    for name, label, ports in rows:
        hit = label == key or name == key or name == f"breakinglab_{key}" or name.startswith(f"{key}_")
        if not hit:
            continue
        running = True
        if "0.0.0.0:" in ports:
            public = True
        for port in HOST_PORT.findall(ports):
            if port not in seen:
                seen.add(port)
                ports_found.append(port)
    return running, public, ports_found


def lan_ips():
    found = []
    seen = set()

    def take(text):
        for line in text.splitlines():
            ip = line.strip()
            if ip and ip not in seen:
                seen.add(ip)
                found.append(ip)

    exe = shutil.which("powershell.exe") or shutil.which("powershell")
    if exe:
        try:
            out = subprocess.run(
                [
                    exe,
                    "-NoProfile",
                    "-Command",
                    "Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' -and $_.InterfaceAlias -notlike 'vEthernet*' -and $_.InterfaceAlias -notlike 'Loopback*' } | ForEach-Object { $_.IPAddress }",
                ],
                check=False,
                capture_output=True,
                text=True,
                timeout=15,
            )
            take(out.stdout)
        except (OSError, subprocess.TimeoutExpired):
            pass
    if found:
        return found
    if shutil.which("ip"):
        try:
            out = subprocess.run(
                ["ip", "-4", "-o", "addr", "show", "scope", "global"],
                check=False,
                capture_output=True,
                text=True,
                timeout=10,
            )
            for line in out.stdout.splitlines():
                parts = line.split()
                if len(parts) >= 4:
                    take(parts[3].split("/")[0])
        except (OSError, subprocess.TimeoutExpired):
            pass
    return found


def url_path(url):
    if not url:
        return "/"
    match = URL_HOST.match(url)
    path = match.group(1) if match else ""
    return path if path.startswith("/") else f"/{path}" if path else "/"


def private_href(lab):
    url = lab.get("url") or ""
    if url.startswith("http://") or url.startswith("https://"):
        return url
    if url:
        return f"http://{url}"
    port = lab.get("port") or ""
    ip = lab.get("ip") or "127.0.0.1"
    return f"http://{ip}:{port}/" if port else f"http://{ip}/"


def show_text(href):
    return re.sub(r"^https?://", "", href)


def lab_links(lab, public, host_ports, ips):
    if public:
        ports = host_ports or ([lab["port"]] if lab.get("port") else [])
        path = url_path(lab.get("url"))
        links = []
        for ip in ips:
            for index, port in enumerate(ports):
                suffix = path if index == 0 else "/"
                href = f"http://{ip}:{port}{'' if suffix == '/' else suffix}"
                links.append({"href": href, "text": show_text(href)})
        return links
    href = private_href(lab)
    return [{"href": href, "text": show_text(href)}]


def snapshot():
    rows = docker_rows()
    ips = lan_ips()
    body = []
    for lab in read_labs():
        running, public, host_ports = lab_state(lab, rows)
        item = dict(lab)
        item["running"] = running
        item["public"] = public
        item["private_links"] = lab_links(lab, False, [], ips)
        item["public_links"] = lab_links(lab, True, host_ports, ips)
        body.append(item)
    return body


def banner_version():
    path = ROOT / "breakinglab.sh"
    ns = path.stat().st_mtime_ns
    moment = datetime.fromtimestamp(ns / 1_000_000_000).astimezone()
    nano = ns % 1_000_000_000
    return f"v.{moment.strftime('%Y-%m-%d %H:%M:%S')}.{nano:09d} {moment.strftime('%z')}"


def clean_log(text, limit=80):
    raw = ANSI.sub("", text or "").replace("\r\n", "\n").replace("\r", "\n")
    lines = [line.rstrip() for line in raw.splitlines()]
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    if len(lines) > limit:
        lines = lines[-limit:]
    return "\n".join(lines)


def wsl_path(path):
    text = str(Path(path).resolve())
    if len(text) >= 2 and text[1] == ":":
        return f"/mnt/{text[0].lower()}{text[2:].replace('\\', '/')}"
    return text.replace("\\", "/")


def run_launcher(args, confirm=False):
    env = dict(**{k: v for k, v in __import__("os").environ.items()})
    env["BREAKINGLAB_BATCH"] = "1"
    if confirm:
        env["BREAKINGLAB_PUBLIC_CONFIRM"] = "1"
    proc = subprocess.run(
        ["bash", wsl_path(ROOT / "breakinglab.sh"), *args],
        cwd=ROOT,
        env=env,
        capture_output=True,
        text=True,
        timeout=600,
    )
    return proc.returncode, proc.stdout + proc.stderr


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        return

    def send_json(self, code, payload):
        raw = json.dumps(payload).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def send_file(self, path, content_type):
        if not path.is_file():
            self.send_error(404)
            return
        raw = path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def do_GET(self):
        path = urlparse(self.path).path
        if path in ("/", "/index.html"):
            self.send_file(WEB / "index.html", "text/html; charset=utf-8")
        elif path == "/app.css":
            self.send_file(WEB / "app.css", "text/css; charset=utf-8")
        elif path == "/app.js":
            self.send_file(WEB / "app.js", "text/javascript; charset=utf-8")
        elif path == "/splash.svg":
            self.send_file(ROOT / "assets" / "preview" / "splash.svg", "image/svg+xml")
        elif path == "/TIIZSS_Logo.png":
            self.send_file(WEB / "TIIZSS_Logo.png", "image/png")
        elif path == "/api/labs":
            self.send_json(200, {"labs": snapshot(), "version": banner_version()})
        else:
            self.send_error(404)

    def do_POST(self):
        path = urlparse(self.path).path
        parts = [p for p in path.split("/") if p]
        if len(parts) != 4 or parts[0] != "api" or parts[1] != "labs":
            self.send_error(404)
            return
        name, action = parts[2], parts[3]
        if not LAB_NAME.match(name) or action not in ("start", "stop", "public"):
            self.send_json(400, {"error": "Petición no reconocida."})
            return
        length = int(self.headers.get("Content-Length", "0") or 0)
        raw = self.rfile.read(length) if length else b"{}"
        try:
            body = json.loads(raw.decode("utf-8") or "{}")
        except json.JSONDecodeError:
            body = {}
        confirm = bool(body.get("confirm"))
        if action == "public" and not confirm:
            others = [lab["name"] for lab in snapshot() if lab["running"] and lab["name"] != name]
            if others:
                self.send_json(409, {"running": others})
                return
        command = {"start": ["start", name], "stop": ["stop", name], "public": ["startpublic", name]}[action]
        code, output = run_launcher(command, confirm=confirm and action == "public")
        if code == 0:
            self.send_json(200, {"ok": True, "labs": snapshot(), "log": clean_log(output)})
            return
        if "PUBLIC_BUSY" in output:
            busy = []
            for line in output.splitlines():
                if line.startswith("PUBLIC_BUSY "):
                    busy = line.split()[1:]
            self.send_json(409, {"running": busy})
            return
        self.send_json(500, {"error": clean_log(output) or "El lanzador no arrancó la máquina.", "log": clean_log(output)})


def main():
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"BreakingLab en http://{HOST}:{PORT}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
