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

(defun get-mark-content (buffername)
  (with-current-buffer
      buffername
    (buffer-substring-no-properties
     (region-beginning)
     (region-end))))

(defun format-clj-deps (pom-list)
  (insert
   (concat
    "\n" (nth 0 pom-list) "/"
    (nth 1 pom-list) " "
    "{:mvn/version \""
    (nth 2 pom-list)
    "\"}\n")))

(defun get-marked-pom-deps-list ()
  (let* ((marked-stri (get-mark-content (current-buffer)))
         (stris (split-string marked-stri "\n"))
         (pom-list
          (-map
           (lambda (stri)
             (replace-regexp-in-string re-<> "\\3" stri))
           (-filter
            (lambda (stri)
              (string-match re-pom stri))
            stris))))
    pom-list))

(defun pom->clj ()
  (interactive)
  (let* ((pom-list
          (get-marked-pom-deps-list)))
    (progn
      (kill-region (region-beginning) (region-end))
      (format-clj-deps pom-list))))

(defun format-lein-deps (pom-list)
  (insert
   (concat
    "\n[" (nth 0 pom-list) "/"
    (nth 1 pom-list) " "
    "\""
    (nth 2 pom-list)
    "\"]\n")))

(defun pom->lein ()
  (interactive)
  (let* ((pom-list
          (get-marked-pom-deps-list)))
    (progn
      (kill-region (region-beginning) (region-end))
      (format-lein-deps pom-list))))

(provide 'jim-config)
