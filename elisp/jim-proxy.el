;; (setq url-gateway-method 'socks)
;; (setq socks-server '("Default server" "127.0.0.1" 1087 5))

(setq url-proxy-services
      '(("no_proxy" . "^\\(localhost\\|10.*\\)")
        ("http" . "http://127.0.0.1:1087")
        ("https" . "http://127.0.0.1:1087")))

(defun show-proxy ()
  "Show http/https proxy."
  (interactive)
  (if url-proxy-services
      (message "Current proxy is \"%s\"" "127.0.0.1:1087")
    (message "No proxy")))

(defun set-proxy ()
  "Set http/https proxy."
  (interactive)
  (setq url-proxy-services `(("http" . ,"127.0.0.1:1087")
                             ("https" . ,"127.0.0.1:1087")))
  (show-proxy))

(defun unset-proxy ()
  "Unset http/https proxy."
  (interactive)
  (setq url-proxy-services nil)
  (show-proxy))

(defun toggle-proxy ()
  "Toggle http/https proxy."
  (interactive)
  (if url-proxy-services
      (unset-proxy)
    (set-proxy)))

(provide 'jim-proxy)
