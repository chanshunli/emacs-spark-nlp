;; for dev: 设置当前的路径在哪里
;; (setq  default-directory "/Users/clojure/BCPro/biancheng-api")

;; (vc-root-dir) ;;=> 获取当前的git的root在哪里

(defun get-sql-files ()
  (->
   (shell-command-to-string
    "find . -name '*.sql'")
   (split-string "\n")))

(defun get-last-sql-number ()
  (let* ((sqls (get-sql-files))
         (number-list (->>
                       sqls
                       (-map
                        (lambda (x)
                          (nth 2 (split-string x "/\\|-"))))
                       (-filter
                        (lambda (x) (not (null x))))
                       (-map
                        (lambda (x)
                          (string-to-number x)))
                       (-sort '>))))
    (first number-list)))

(defun alter-table-add-column-tpl (table column)
  (format "ALTER TABLE `%s` ADD COLUMN `%s` VARCHAR(32);"
          table column))

(defun alter-table-remove-column-tpl (table column)
  (format "ALTER TABLE `%s` DROP COLUMN `%s`"
          table column))

;; (generate-sql-files "users" "picture")
(defun generate-sql-files (table column)
  (let* ((file-name-fn
          (lambda (up-or-down)
            (format "%smigrations/0%s-%s-%s-%s.%s.sql"
                    (vc-root-dir)
                    (+  (get-last-sql-number) 1)
                    table
                    (cond ((string= up-or-down "add") "add")
                          ((string= up-or-down "remove") "remove"))
                    column
                    (cond ((string= up-or-down "add") "up")
                          ((string= up-or-down "remove") "down")))))
         (up-sql-file-name (funcall file-name-fn "add"))
         (down-sql-file-name (funcall file-name-fn "remove")))
    (list up-sql-file-name down-sql-file-name)))

(provide 'jim-scaffold)
