;;;  ;;;;;; ENV setting ;;;;
(setq project-name "")

(setq start-cljs-file "")

(setq start-clj-file "")

(require 'jim-env)

;;;  ;;;;;; 一键启动clj和cljs的cider repl

(setq cljs-buffer-name "")

;; (get-cljs-buffer-name (get-cider-port))
(defun get-cljs-buffer-name (port)
  (format "%s%s%s%s%s"
          "*cider-repl " project-name ":localhost:"
          port "(cljs:shadow)*"))

(defun open-cljs-file ()
  (find-file start-cljs-file))

(defun get-cider-port ()
  (with-current-buffer cljs-buffer-name
    (plist-get (cider--gather-connect-params) :port)))

;; DO 2 ;
(defun set-cider-buffer-name ()
  (setq cljs-buffer-name
        (->> (buffer-list)
             (-filter
              (lambda (buffer-name)
                (let* ((name (format "%s" buffer-name)))
                  (string-match "*cider-repl*" name))))
             first
             (format "%s"))))

(setq sibl-run "false")

;; DO 1 ;
(defun jackj ()
  (interactive)
  (let* ((buffer-name (->
                       start-cljs-file
                       (split-string "/")
                       last
                       car)))
    (progn
      (message "Jack in cljs cider...")
      (setq sibl-run "false")
      (open-cljs-file)
      (switch-to-buffer buffer-name)
      (with-current-buffer
          buffer-name
        (jack)))))

;; DO 3 ;
(defun siblj ()
  (interactive)
  (if (equal sibl-run "false") ;; 如果不加这一行,只分一次sibl clj,就会死循环启动
      (progn
        (setq sibl-run "true")
        (message "从cljs的repl(包含了clj)分出来一个clj的repl...")
        (set-cider-buffer-name)
        (switch-to-buffer cljs-buffer-name)
        (with-current-buffer cljs-buffer-name
          (sibl))
        (find-file start-clj-file))
    (message "sibl已经启动")))

;; 把 DO1 2 3 连起来,当启动第一步成功的时候启动第二步
(add-hook 'cider-connected-hook 'siblj)

(provide 'jim-config)
