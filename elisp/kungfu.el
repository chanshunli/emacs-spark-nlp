;;; kungfu.el --- Minor mode for interactive development for Ruby Gem.
;;; -*- coding: utf-8 -*-

;;; Commentary:



;;; Code:
;;; ----------------------------------------------------------------------------
(require 'cl)
(defgroup kungfu nil
  "Minor mode for interactive development for Ruby Gem."
  :group 'languages)

(defvar kungfu-path (concat "  " (getenv "PWD")) )

(defun get-messages-content ()
  (with-current-buffer "*Messages*"
    (buffer-substring-no-properties (point-min) (point-max))))

(defun get-messages-last-line ()
  (car
   (last
    (butlast
     (split-string (get-messages-content) "\n") ))) )

(defun get-mark-content (buffername)
  "Get region marked content in `BUFFERNAME'."
  (with-current-buffer buffername
    (buffer-substring-no-properties (region-beginning) (region-end))))

(defun get-point-keyword ()
  "Get point symbol."
  (set-mark-command nil)
  (forward-sexp 1)
  (get-mark-content (current-buffer)))

(defun relace-region-str (str)
  (progn
    (kill-region (region-beginning) (region-end))
    (insert str)))

(defun downcase-str ()
  (let ((str (get-mark-content (current-buffer))))
    (downcase str)))

(defun drb-shell (cmd fn &rest args) 
  (let* ((args
	  (if (null args) ""
	    (concat " '" (reduce (lambda (s i) (concat s "' '" i)) args) "' ") ))
	 (cmd-str
	  (concat "drb" kungfu-path
		  "/drb-help/" cmd ".drb " args)))
    (funcall fn (shell-command-to-string cmd-str))
    )
  )

(defmacro drb-commands (cmd)
  `(defun ,(intern (format "rb-%s" cmd)) (str)
     (drb-shell
      (format "rb-%s" ,cmd)
      (lambda (com-str) com-str)
      str) )
  )

(drb-commands "underscore")
(drb-commands "camelize")
(drb-commands "parser")
(drb-commands "source-location")

(defun rb-parser-mark ()
  (interactive)
  (rb-parser (get-mark-content (current-buffer)))
  )

(defun rb-underscore-words ()
  (interactive)
  (rb-underscore (get-point-keyword)) )

;; ;; Usage: (get-api-to-doc "http://127.0.0.1:3000/api/dasddsa")
;; (defun get-api-to-doc (url)
;;   (let ((url-cmd   (concat " drb " kungfu-path "/drb-help/http.drb " url)))
;;     (shell-command-to-string url-cmd)
;;     )
;;   )
;; (add-to-list 'load-path (concat kungfu-path "/apib-mode") )
;; (autoload 'apib-mode "apib-mode"
;;   "Major mode for editing API Blueprint files" t)
;; (add-to-list 'auto-mode-alist '("\\.apib\\'" . apib-mode))
;;

;;;;;;;;;;
(defun get-mark-content-for-bash (buffername)
  (replace-regexp-in-string "`" "'" (get-mark-content buffername)))

;;; 就像zshrc一样使用Elisp: alias v=' vi ~/.zshrc ; echo "Source zshrc ... "; source ~/.zshrc  ' 
(defun source ()
  (interactive)
  (load-file (concat kungfu-path "/init.el")))

;; ;; Eval: (http-send-apiary "users" "post")
;; (defun http-send-apiary (url http-method)
;;   (shell-command-to-string (concat " drb " kungfu-path "/drb-help/http_send_for_apiary.drb " "http://localhost:3000/api/" url "  \" " (get-mark-content-for-bash (current-buffer)) "\" " http-method ) ) )
;; 
;; ;; 只是单个参数,可以不用Mark,而获取当前行的内容
;; (defun http-one-params (url http-method)
;;   (shell-command-to-string (concat " drb " kungfu-path "/drb-help/http_send_for_apiary_one.drb " "http://localhost:3000/api/" url "  \" " (get-mark-content-for-bash (current-buffer)) "\" " http-method ) ) )
;; 
;; (defun http-send-apiary-params (url http-method)
;;   (shell-command-to-string (concat " drb " kungfu-path "/drb-help/http_send_for_apiary_params.drb " "http://localhost:3000/api/" url "  \" " (get-mark-content-for-bash (current-buffer)) "\" " http-method ) ) )
;; 
;; ;; (inf-ruby-switch-setup) + ` C-x C-q `
;; (defun ininf ()
;;   (inf-ruby-switch-setup)
;;   (inf-ruby-maybe-switch-to-compilation)
;;   )
;; 
;; http://docs.huihoo.com/homepage/shredderyin/emacs_elisp.html ==> (read-char)
;; `C-c a `=> Mark 向下一个的光标, 或者不要Mark的向下的一个字符
;; "aaaaaaaaaaaaaaaaaaaaa"
(defun wy-go-to-char (n char)
  "Move forward to Nth occurence of CHAR.
Typing `wy-go-to-char-key' again will move forwad to the next Nth
occurence of CHAR."
  (interactive "p\ncGo to char: ")
  (search-forward (string char) nil nil n)
  (while (char-equal (read-char) char)
    (search-forward (string char) nil nil n))
  (setq unread-command-events (list last-input-event)))

;;; Emacs查看Ruby的函数定义跳转: Mark "obj.method" => rb-source
(defun rb-source (obj-call-method)
  (interactive)
  (car
   (last
    (read
     (rb-source-location obj-call-method)
     )))
  )

(defvar rb-obj-root nil)
(defvar rb-method-root nil)
(defun rb-file-infos ()
  (setq 
   obj-method (get-mark-content (current-buffer))
   file-and-line (rb-source obj-method)
   rb-file (first file-and-line)
   rb-line (first (last file-and-line))
   rb-buffer (first (last (split-string rb-file "/")))
   rb-obj (first (split-string obj-method "\\."))
   )
  )
;; Mark "instace.method" => "C-c g"
(defun rb-source-find ()
  (interactive)
  (progn
    (rb-file-infos)
    (find-file rb-file)
    (goto-line rb-line rb-buffer)
    (setq rb-obj-root rb-obj)
    (message
     (concat "cool, open the file: " rb-file
	     " , " (number-to-string rb-line) " , " rb-obj))
    )
  )

;; Mark "instace_method" => "C-c n"
(defun rb-source-find-next ()
  (interactive) ;;;; only diff in obj-method
  (let* ((obj-method
	  (concat rb-obj-root "." (get-mark-content (current-buffer))))
	 (file-and-line (rb-source obj-method)))
    (if (first file-and-line)
	(let* ((rb-file (first file-and-line))
	       (rb-line (first (last file-and-line)))
	       (rb-buffer (first (last (split-string rb-file "/"))))
	       (rb-obj (first (split-string obj-method "\\."))))
	  (progn
	    (find-file rb-file)
	    (goto-line rb-line rb-buffer)
	    (setq rb-obj-root rb-obj)
	    (message
	     (concat "cool, open the file: " rb-file
		     " , " (number-to-string rb-line) " , " rb-obj)) ))
      (progn
	(setq rb-method-root (first (last file-and-line)))
	(message
	 (concat "please go to rb-method-root : " rb-method-root
		 " , Run : C-c b")) ))))

;;; No need Mark any, use (buffer-file-name) as Class name, rb-method-root as method name => ` C-c b `
(defun rb-source-find-next-super ()
  (interactive) ;;;; only diff in obj-method
  (let* ((obj-method
	  (concat
	   (rb-camelize
	    (first (split-string
		    (first (last (split-string (buffer-file-name) "lib/")))
		    "\\."))) "." rb-method-root))
	 (file-and-line
	  (rb-source obj-method))
	 (rb-file (first file-and-line))
	 (rb-line (first (last file-and-line)))
	 (rb-buffer (first (last (split-string rb-file "/"))))
	 (rb-obj (first (split-string obj-method "\\."))))
    (progn
      (find-file rb-file)
      (goto-line rb-line rb-buffer)
      (message
       (concat "cool, open the file: " rb-file
	       " , " (number-to-string rb-line) " , " rb-obj))) ))

;; Like `C-x C-e` eval the ruby expression, such as: `User.first.id` => 3
(defun rb-eval (str)
  (interactive)
  (let ((cmd-str
         (concat "drb " kungfu-path
                 "/drb-help/binding_eval.drb "
                 "'" str "'")))
    (message (shell-command-to-string cmd-str))))

(defun rb-eval-var ()
  (interactive)
  (let ((cmd-str
         (concat "drb " kungfu-path
                 "/drb-help/binding_eval.drb "
                 (get-point-keyword))))
    (progn
      ;;(keyboard-quit) 
      (message (shell-command-to-string cmd-str))
      )))

;;;;for testdatas
(defun rb-eval9018 ()
  (interactive)
  (let ((cmd-str
         (concat "drb9018 " kungfu-path
                 "/drb-help/binding_eval.drb "
                 (get-mark-content (current-buffer)))))
    (message (shell-command-to-string cmd-str))
    ))

;;;;=> 如果是测试纯函数方法,需要提取方法上面的注释内容作为测试用法, 在drb服务端用lambda包住传进来的方法定义放上面＋注释用法调用放下面 : `#update_has_many_relation User.last(2), :post { |post| post.name="steve" } `
;; ==> 解决双单引号报错的问题
;; ` "aaa dsadas dsads".gsub(/a/, 'A') ` ==> (get-rb-obj-body) ==> "  \"aaa dsadas dsads\".gsub(/a/, 'A') "
;;; ===> ;; %Q{aaa dsadas dsads}.gsub(/a/, %q{A}) 已支持 ==> "AAA dsAdAs dsAds"
(defun rb-eval-expression-at ()
  (interactive)
  (let ((cmd-str
         (concat "drb " kungfu-path
                 "/drb-help/binding_eval.drb "
                 (get-rb-obj-body))))
    ;; cmd-str ==> "drb /home/clojure/drb-help/binding_eval.drb \"  \"aaa dsadas dsads\".gsub(/a/, 'A') \""
    (message (shell-command-to-string cmd-str))
    ))

;;; for other testdatas project: drb9018
(defun rb-eval-expression-at9018 ()
  (interactive)
  (let ((cmd-str
         (concat "drb9018 " kungfu-path
                 "/drb-help/binding_eval.drb "
                 (get-rb-obj-body))))
    (message (shell-command-to-string cmd-str))
    ))

;;;;;;;;; prod export data to dev
(defun prod-to-dev-datas ()
  (interactive)
  (let ((cmd-str
         (concat "drb9018 " kungfu-path
                 "/drb-help/binding_eval_prod_to_dev.drb "
                 (get-rb-obj-body))))
    (message (shell-command-to-string cmd-str))
    ))
;;;;;;;;;;;;;; for spec
(defun spec-app-file ()
  (replace-regexp-in-string
   "spec" "app"
   (replace-regexp-in-string "_spec" "" (buffer-file-name))))

(defun app-spec-file ()
  (replace-regexp-in-string
   "app" "spec"
   (replace-regexp-in-string ".rb" "_spec.rb" (buffer-file-name))))

(defun open-spec () (interactive) (find-file (app-spec-file)))
(defun open-app () (interactive) (find-file (spec-app-file)))
;;;;;;;;;;;;;;;;

;;; The brakeman help parse the rails project
(defun method-find-call ()
  (interactive)
  (let ((cmd-str
         (concat "drb9 " kungfu-path
                 "/drb-help/method-find-call.drb9 "
                 (get-mark-content (current-buffer))))) 
    (message (shell-command-to-string cmd-str))))

(defun is-rb-params ()
  (interactive)
  (let ((cmd-str
         (concat kungfu-path
                 "/rkt-help/params_type "
                 (ruby-parser-mark))))
    (message (shell-command-to-string cmd-str))))

;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;
;; %Q{aaa dsadas dsads}.gsub(/a/, %q{A}) 已支持
(defun get-rb-obj-body ()
  (interactive)
  (let ((cmd-str
         (concat "drb " kungfu-path
                 "/drb-help/expression_at.rb "
                 (buffer-file-name)
                 "  " (number-to-string (line-number-at-pos)))))
    (shell-command-to-string cmd-str)))

;;; (get-rb-obj-body-line-number 1) ==> 获取注释下面一行的表达式体
(defun get-rb-obj-body-line-number (line-number)
  (interactive)
  (line-number-at-pos)
  (let ((cmd-str
         (concat "drb " kungfu-path
		 "/drb-help/expression_at.rb "
                 (buffer-file-name)
                 "  " (number-to-string (+ line-number (line-number-at-pos))))))
    (message (shell-command-to-string cmd-str))))

;;  # aaa 1
;;  def aaa a
;;    a + 1
;;  end   
;;; rb-eval-expression-at-lambda ===> 2
(defun rb-eval-expression-at-lambda ()
  (interactive)
  (let ((cmd-str
         (concat "drb " kungfu-path "/drb-help/binding_eval.drb "
		 "' " "-> { " 
		 (get-rb-obj-body-line-number 1) " ; "
		 (replace-regexp-in-string
		  "^[[:space:]]?#" ""
		  (get-rb-obj-body-line-number 0)) 
		 " }[] " " '"
		 )))
    (message (shell-command-to-string cmd-str) )) )

;;;;;;;;; Ruby纯函数 + `Use db/scheme.rb  & rails scaffold for test & factoryGril as datas`
;;;;; 下一个问题是什么: drb 的错误事件捕捉及对应类型生成代码, 用AutoFixErro的我写的Gem去做　==>> `C-c j or C-c p ` drb的错误处理中心，处理错误事件发生的处理, 如果发现不关联那就生成关联语句到项目drb的服务端, 并自动重启drb server服务端
(defun rails-scaffold-by-sch ()
  (interactive)
  (line-number-at-pos)
  (let ((cmd-str
         (concat "drb " kungfu-path
                 "/drb-help/expression_at_for_schema.drb "
                 (buffer-file-name)  "  "
                 (number-to-string (line-number-at-pos)))))
    (progn 
      (message (concat "Run: " (shell-command-to-string cmd-str)))
      (shell-command-to-string (shell-command-to-string cmd-str))
      (shell-command-to-string " rake db:migrate "))
    )
  )

(defun rails-scaffold-str ()
  (line-number-at-pos)
  (let ((cmd-str
         (concat "drb " kungfu-path
                 "/drb-help/expression_at_for_schema.drb "
                 (buffer-file-name)  "  "
                 (number-to-string (line-number-at-pos)))))
    (progn
      (message (shell-command-to-string cmd-str)))))

;;; 检查drb server 9000 是否启动 ;;;;;;;; drb传异常给Emacs
(defun drb-server-check ()
  (if (equal (rb-eval "1") "1")
      (message "The drb server is start")
    (progn (message "========= The drb server is not start, please start the drb server by code: 'drb_start binding' in your ruby code :)=======") (suspend-frame)) ) )

(defvar kungfu-mode-map
  (let ((map (make-sparse-keymap)))
    ;; TODO:
    (define-key map (kbd "") 'rb-underscore-words)
    (define-key map (kbd "") 'ruby-parser-mark)
    (define-key map (kbd "") 'wy-go-to-char)
    (define-key map (kbd "") 'rb-source-find)
    (define-key map (kbd "") 'rb-source-find-next)
    (define-key map (kbd "") 'rb-source-find-next-super)
    (define-key map (kbd "") 'rb-eval)
    (define-key map (kbd "") 'rb-eval-var)
    (define-key map (kbd "") 'rb-eval9018) ;; C-x p
    (define-key map (kbd "") 'rb-eval-expression-at)
    (define-key map (kbd "") 'rb-eval-expression-at9018) ;; C-x j
    ;; (define-key map (kbd "") 'get-rb-obj-body)
    ;; C-c C-j 整体  + C-c p 局部 Mark + C-c t wy-go-to-char
    (define-key global-map (kbd "C-c C-j") 'rb-eval-expression-at-lambda)
    map))

(define-minor-mode kungfu-mode
  "Minor mode for interactive development for Ruby Gem.

The following commands are available:

\\{kungfu-mode-map}"
  nil " kungfu" kungfu-mode-map
  (add-hook 'ruby-mode-hook 'kungfu-mode)
  (add-hook 'enh-ruby-mode-hook 'kungfu-mode)
  )

(provide 'kungfu)

;;; kungfu.el ends here
