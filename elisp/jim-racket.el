
(add-hook 'racket-mode-hook 'lispy-mode)


(defun rkt-datalog-head ()
  "一个问题在某个领域很难,但是跳出这个领域,变成另外一个领域很简单的问题:https://docs.racket-lang.org/datalog/"
  (interactive)
  (insert "#lang datalog\n(racket/base).\n"))

(defun rkt-datalog-head-sexp ()
  "用S表达式来写datalog: https://docs.racket-lang.org/datalog/Parenthetical_Datalog_Module_Language.html ## 可以写注释了"
  (interactive)
  (insert "#lang datalog/sexp\n(require racket/math)\n"))

(defun rkt-datalog-interop ()
  "Racket 和 他的新语言的互操作: https://docs.racket-lang.org/datalog/interop.html"
  (interactive)
  (insert "#lang racket\n(require datalog)"))

(provide 'jim-racket)
