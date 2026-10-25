CREATE TABLE IF NOT EXISTS users (
  idusers INT NOT NULL,
  name VARCHAR(45) NOT NULL,
  email VARCHAR(45) NOT NULL,
  password VARCHAR(45) NOT NULL,
  ua VARCHAR(45) NOT NULL,
  ref VARCHAR(145) NOT NULL,
  host VARCHAR(45) NOT NULL,
  lang VARCHAR(45) NOT NULL,
  PRIMARY KEY (idusers)
);

INSERT INTO users (idusers, name, email, password, ua, ref, host, lang) VALUES
(0, 'admin', 'admin@getmantra.com', 'admin', 'Brick_Browser', 'http://127.21.0.1/bricks/content-13/index.php', '127.0.0.1', 'en'),
(1, 'tom', 'tom@getmantra.com', 'tom', 'Block_Browser', '', '8.8.8.8', 'en'),
(2, 'ron', 'ron@getmantra.com', 'ron', 'Rain_Browser', '', '192.168.1.1', 'en'),
(3, 'harry', 'harry@getmantra.com', '5f4dcc3b5aa765d61d8327deb882cf99', 'Mantra', '', '127.0.0.1', 'en');
