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

;; DO 1 ;
(defun jackj ()
  (interactive)
  (let* ((buffer-name (->
                       start-cljs-file
                       (split-string "/")
                       last car)))
    (progn
      (open-cljs-file)
      (switch-to-buffer buffer-name)
      (with-current-buffer buffer-name
        (jack))
      ;; TODO: 把 DO1 2 3 连起来,当启动第一步成功的时候启动第二步
      (thread-first
          (progn
            (sleep-for 10)
            (message "设置cider变量...")
            (set-cider-buffer-name)))
      ;;
      )))

;; DO 3 ;
(defun siblj ()
  (interactive)
  (switch-to-buffer cljs-buffer-name)
  (with-current-buffer cljs-buffer-name
    (sibl)))

(provide 'jim-config)
