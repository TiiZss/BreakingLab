#!/usr/bin/env bash
# Un stack por máquina: breakinglab_<clave>. Compose no acepta "BreakingLab".

if [ -z "${BL_DIR:-}" ]; then
    BL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

STACK_NAME=breakinglab

bl_stack_name() {
    printf '%s_%s\n' "$STACK_NAME" "$1"
}

# Nombre en Docker Hub de tiizss. La versión de MySQL, PHP, Postgres y Mongo va en el repositorio.
bl_pin_image() {
    local image="$1"
    case "$image" in
        tiizss/*) printf '%s\n' "$image" ;;
        mysql:5.7|library/mysql:5.7) printf '%s\n' "tiizss/mysql-5.7:5.7" ;;
        mysql:5.5|library/mysql:5.5) printf '%s\n' "tiizss/mysql-5.5:5.5" ;;
        mysql:8|library/mysql:8) printf '%s\n' "tiizss/mysql-8:8" ;;
        mongo:3.4.1|library/mongo:3.4.1) printf '%s\n' "tiizss/mongo-3.4.1:3.4.1" ;;
        mongo:4.0.4|library/mongo:4.0.4) printf '%s\n' "tiizss/mongo-4.0.4:4.0.4" ;;
        postgres:15.4-alpine|library/postgres:15.4-alpine) printf '%s\n' "tiizss/postgres-15.4-alpine:15.4-alpine" ;;
        php:8.1.28-apache-bullseye|library/php:8.1.28-apache-bullseye) printf '%s\n' "tiizss/php-8.1.28-apache-bullseye:8.1.28-apache-bullseye" ;;
        cspf/jvl|cspf/jvl:latest) printf '%s\n' "tiizss/jvl:latest" ;;
        webpwnized/mutillidae:*) printf '%s\n' "tiizss/mutillidae:${image#webpwnized/mutillidae:}" ;;
        nosqli-labs|nosqli-labs:latest) printf '%s\n' "tiizss/nosqli-labs:latest" ;;
        raesene/bwapp|raesene/bwapp:latest) printf '%s\n' "tiizss/bwapp:latest" ;;
        webgoat/webgoat-7.1|webgoat/webgoat-7.1:latest) printf '%s\n' "tiizss/webgoat-7.1:latest" ;;
        vulnerables/web-dvwa|vulnerables/web-dvwa:latest) printf '%s\n' "tiizss/web-dvwa:latest" ;;
        c0ny1/sqli-labs:0.1) printf '%s\n' "tiizss/sqli-labs:0.1" ;;
        bkimminich/juice-shop|bkimminich/juice-shop:latest) printf '%s\n' "tiizss/juice-shop:latest" ;;
        owasp/security-shepherd|owasp/security-shepherd:latest) printf '%s\n' "tiizss/security-shepherd:latest" ;;
        eystsen/altoro|eystsen/altoro:latest) printf '%s\n' "tiizss/altoro:latest" ;;
        eystsen/vulnerablewordpress|eystsen/vulnerablewordpress:latest) printf '%s\n' "tiizss/vulnerablewordpress:latest" ;;
        devsecopsacademy/vulpy:v1.2.0) printf '%s\n' "tiizss/vulpy:v1.2.0" ;;
        citizenstig/owaspbricks|citizenstig/owaspbricks:latest) printf '%s\n' "tiizss/bricks:2.2" ;;
        opendns/security-ninjas|opendns/security-ninjas:latest) printf '%s\n' "tiizss/security-ninjas:2015.05.01" ;;
        dolevf/dvga|dolevf/dvga:latest) printf '%s\n' "tiizss/dvga:2.1.2" ;;
        owasp/webgoat:v8.2.2) printf '%s\n' "tiizss/webgoat-8.2.2:v8.2.2" ;;
        webgoat/webgoat-8.0|webgoat/webgoat-8.0:latest) printf '%s\n' "tiizss/webgoat-8.0.0:v8.0.0" ;;
        webgoat/webgoat:v8.1.0|webgoat/goatandwolf|webgoat/goatandwolf:latest) printf '%s\n' "tiizss/webgoat-8.1.0:v8.1.0" ;;
        *) printf '%s\n' "$image" ;;
    esac
}

bl_pin_compose_file() {
    local file="$1"
    local tmp="$2"
    local line value pinned
    : >"$tmp"
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^([[:space:]]*image:[[:space:]]*)[\"\']?([^\"\']+)[\"\']?[[:space:]]*$ ]]; then
            value="${BASH_REMATCH[2]}"
            pinned="$(bl_pin_image "$value")"
            printf '%s%s\n' "${BASH_REMATCH[1]}" "$pinned" >>"$tmp"
        else
            printf '%s\n' "$line" >>"$tmp"
        fi
    done <"$file"
    mv "$tmp" "$file"
}

bl_render_compose() {
    local proj="$1"
    local src="$2"
    local dest="$3"
    local raw

    raw="$(mktemp)"
    if ! docker compose -p "$(bl_stack_name "$proj")" -f "$src" config >"$raw"; then
        rm -f "$raw"
        return 1
    fi
    bl_pin_compose_file "$raw" "${raw}.pin"

    awk -v proj="$proj" '
        function key_of(line,    k) {
            k = line
            gsub(/^[[:space:]]+/, "", k)
            gsub(/:.*/, "", k)
            return k
        }
        function mark_section(line) {
            if (line ~ /^services:/) return "s"
            if (line ~ /^networks:/) return "n"
            if (line ~ /^volumes:/) return "v"
            if (line ~ /^[A-Za-z]/) return ""
            return "SAME"
        }
        {
            lines[++n] = $0
            sec = mark_section($0)
            if (sec != "SAME") sect = sec
            if (sect == "s" && $0 ~ /^  [A-Za-z0-9_.-]+:$/) svc[key_of($0)] = 1
            if (sect == "v" && $0 ~ /^  [A-Za-z0-9_.-]+:$/) vol[key_of($0)] = 1
        }
        END {
            sect = ""
            orig = ""
            volkey = ""
            net_rename = 0
            vol_type = 0
            for (i = 1; i <= n; i++) {
                line = lines[i]
                sec = mark_section(line)
                if (sec != "SAME") {
                    sect = sec
                    net_rename = 0
                }
                if (sect == "s" && line ~ /^[[:space:]]*container_name:/) continue
                if (sect == "s" && line ~ /^  [A-Za-z0-9_.-]+:$/) {
                    orig = key_of(line)
                    print "  " proj "_" orig ":"
                    print "    container_name: " proj "_" orig
                    print "    labels:"
                    print "      breakinglab.lab: " proj
                    continue
                }
                if (sect == "s" && line ~ /^      [A-Za-z0-9_.-]+:$/ && (key_of(line) in svc)) {
                    print "      " proj "_" key_of(line) ":"
                    continue
                }
                if (sect == "s" && line ~ /^[[:space:]]+- /) {
                    val = line
                    sub(/^[[:space:]]+- /, "", val)
                    gsub(/"/, "", val)
                    if (val in svc) {
                        sub(/- .*/, "- " proj "_" val, line)
                        print line
                        continue
                    }
                }
                if (sect == "s" && line ~ /type: volume$/) { vol_type = 1; print line; continue }
                if (sect == "s" && line ~ /type: bind$/) { vol_type = 0; print line; continue }
                if (sect == "s" && vol_type && line ~ /source: /) {
                    val = line
                    sub(/^.*source: /, "", val)
                    if (val in vol) {
                        sub(/source: .*/, "source: " proj "_" val, line)
                        print line
                        continue
                    }
                }
                if (sect == "s" && line ~ /^      [A-Za-z0-9_.-]+: null$/) {
                    nk = key_of(line)
                    if (nk == "default") nk = proj "_net"
                    print "      " nk ":"
                    print "        aliases:"
                    print "          - " orig
                    continue
                }
                if (sect == "v" && line ~ /^  [A-Za-z0-9_.-]+:$/) {
                    volkey = key_of(line)
                    print "  " proj "_" volkey ":"
                    continue
                }
                if (sect == "v" && line ~ /^    name: /) {
                    print "    name: " proj "_" volkey
                    continue
                }
                if (sect == "n" && line ~ /^  default:$/) {
                    print "  " proj "_net:"
                    net_rename = 1
                    continue
                }
                if (sect == "n" && net_rename && line ~ /^    name: /) {
                    print "    name: " proj "_net"
                    net_rename = 0
                    continue
                }
                print line
            }
        }
    ' "$raw" >"$dest"
    rm -f "$raw"
}

bl_compose() {
    local proj="$1"
    local workdir="$2"
    local file="$3"
    shift 3
    local rendered="${BL_DIR}/.breakinglab/${proj}.yml"
    mkdir -p "${BL_DIR}/.breakinglab"
    bl_render_compose "$proj" "${workdir}/${file}" "$rendered" || return 1
    docker compose -p "$(bl_stack_name "$proj")" -f "$rendered" "$@"
}

bl_compose_down() {
    local proj="$1"
    local rendered="${BL_DIR}/.breakinglab/${proj}.yml"
    local id
    if [ -f "$rendered" ]; then
        docker compose -p "$(bl_stack_name "$proj")" -f "$rendered" down >/dev/null 2>&1 || true
    fi
    while IFS= read -r id; do
        [ -z "$id" ] && continue
        docker stop "$id" >/dev/null 2>&1 || true
        docker rm "$id" >/dev/null 2>&1 || true
    done < <(docker ps -aq --filter "label=breakinglab.lab=${proj}")
    while IFS= read -r id; do
        [ -z "$id" ] && continue
        docker rm -f "$id" >/dev/null 2>&1 || true
    done < <(docker ps -aq --filter "name=^${proj}_")
}
