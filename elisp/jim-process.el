
(comment
 ;; 不卡死Emacs编辑的进程
 (set-process-sentinel
  (start-process "sleep" "*sleep*" "sleep" "10")
  (lambda (_process event)
    (when (string= event "finished\n")
      (message "TODO Do something"))))

 ;; 不卡死Emacs编辑的进程
 (make-process
  :name "sleep test"
  :command (list "sleep" "10")
  :sentinel (lambda (proc event) (message "done!"))
  :buffer "*sleep test*")

 ;; 不能执行这个串起来的命令
 (make-process
  :name "touch file to desktop"
  :command (list "sleep" "10" "&&" "cd" "~/Desktop" "&&" "touch" "test.clj")
  :sentinel (lambda (proc event) (message "done!"))
  :buffer "*sleep test*")

 ;; 可以在*test1*这个buffer看到输出
 (make-process
  :name "test 1"
  :command (list "cat" "jim-process.el")
  :sentinel (lambda (proc event) (message "done!"))
  :buffer "*test1*")

 ;; 如果直接写lambda,会获取不到op-fn的定义 => 会有op-fn 为空的错误
 (let* ((op-fn (lambda () (message "call the fn"))))
   (make-process
    :name "sleep test"
    :command (list "sleep" "3")
    :sentinel `(lambda (proc event)
                 (message "done!")
                 (funcall ,op-fn))
    :buffer "*sleep test*"))
 )

;; (my-make-process-call "ls") ;;可以工作的
;; (my-make-process-call "mytail") # `tail -f  /Users/clojure/PytorchPro/pytorch/README.md `
(defun my-make-process-call (program &rest args)
  "Call PROGRAM with ARGS, using BUFFER as stdout+stderr.
If BUFFER is nil, `princ' is used to forward its stdout+stderr."
  (let* ((command `(,program . ,args))
         (_ (message "[my-make-process Running %s in %s" command default-directory))
         (base `(:name ,program :command ,command))
         (output
          `(:filter (lambda (proc string)
                      (princ "打印数据流了:\n")
                      (princ string))))
         (proc (apply #'make-process (append base output)))
         (exit-code (progn
                      (while (not (memq (process-status proc)
                                        '(exit failed signal)))
                        (sleep-for 0.1))
                      (process-exit-status proc))))
    (unless (= exit-code 0)
      (error "Error calling %s, exit code is %s" command exit-code))))

(defun push-mini-program-cljs (version success-fn)
  (make-process
   :name "npm push mini-program-cljs"
   :command (list "/usr/local/bin/npm_push_mini_cljs" version)
   :sentinel `(lambda (proc event)
                (message "finished push the mini-program-cljs!")
                (funcall ,success-fn))
   :buffer "*mini-program-cljs # pushing mini-program-cljs*"))

(comment
 (npm-build-my-mini-pro "0.2.4"))

(defun npm-build-my-mini-pro (version)
  (make-process
   :name "npm_build_my_mini_pro"
   :command (list "/usr/local/bin/npm_build_my_mini_pro" version)
   :sentinel (lambda (proc event)
               (message "finished npm_build_my_mini_pro!"))
   :buffer "*mini-program-cljs # npm_build_my_mini_pro*"))

(defun get-version-mini-pro-cljs ()
  (let*  ((stris
           (->
            "cat /Users/clojure/CljPro/wechat-clj/mini-program-cljs/package.json"
            (shell-command-to-string)
            (split-string "\n")))
          (match-stri (format "%s"
                              (-filter
                               (lambda (x)
                                 (string-match "\\(.*\\)version\\(.*\\)" x))
                               stris))))
    (replace-regexp-in-string
     "\\(.*\\)\"version\": \"\\([0-9|\.]+\\)\"\\(.*\\)"
     "\\2"
     match-stri)))

(defun mini-pro-cljs-update ()
  (interactive)
  (let* ((version
          (format "%s"
                  (read-string
                   (format "Current version is %s:"
                           (get-version-mini-pro-cljs))))))
    (push-mini-program-cljs
     version
     (lambda ()
       (message "======")
       (npm-build-my-mini-pro version)))))

(provide 'jim-process)
