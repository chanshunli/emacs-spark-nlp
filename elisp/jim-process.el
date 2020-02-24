
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

(provide 'jim-process)
