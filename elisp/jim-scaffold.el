;; for dev: 设置当前的路径在哪里
;; (setq  default-directory "/Users/clojure/BCPro/biancheng-api")

;; (vc-root-dir) ;;=> 获取当前的git的root在哪里

;; ------------ mysql 的 增减字段的sql 生成 --------------- start ---
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
            (format "migrations/0%s-%s-%s-%s.%s.sql"
                    ;; (vc-root-dir)
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

;; 坚持去lambda化简单的已知的定点纯函数, 最后组合函数,就能把复杂的事情做出来
;; (generate-alter-sql-file "users" "picture")
;; 在项目root目录下执行: M-x generate-alter-sql-file # 输入两次参数`Table:` & `Column:`
(defun generate-alter-sql-file (table column)
  (interactive "sTable:\nsColumn:")
  (dolist (file (generate-sql-files table column))
    (progn
      (message (format  "Generate alter sql file %s" file))
      (write-region
       (cond ((string-match "\\(.*\\).up.sql" file) (alter-table-add-column-tpl table column))
             ((string-match "\\(.*\\).down.sql" file) (alter-table-remove-column-tpl table column)))
       nil file))))
;; ------------ mysql 的 增减字段的sql 生成 --------------- end -------


(provide 'jim-scaffold)
