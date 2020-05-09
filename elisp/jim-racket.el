

(defun rkt-datalog-head ()
  "一个问题在某个领域很难,但是跳出这个领域,变成另外一个领域很简单的问题:https://docs.racket-lang.org/datalog/"
  (interactive)
  (insert "#lang datalog
(racket/base).\n"))

(defun rkt-datalog-sexp ()
  "用S表达式来写datalog: https://docs.racket-lang.org/datalog/Parenthetical_Datalog_Module_Language.html"
  (interactive)
  (insert "#lang datalog/sexp\n"))

(provide 'jim-racket)
