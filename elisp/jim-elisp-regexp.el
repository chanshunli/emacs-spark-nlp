;; 因为elisp的正则表达式和标准语言的正则表达式不太一样,所以用这个文件来专门记录elisp常用的正则表达式,需要写的时候,看看这个文件参考一下

;; https://www.emacswiki.org/emacs/RegularExpression


;; reg-mark: '.*' 是会匹配 => `'abc', 'efg'`
;; '[A-Za-z]+' 是会匹配 => `'abc'`
;; '[0-9]+' 是会匹配数字 => `12`
;; mc/mark-all-in-region-regexp => '*' 会选中所有的'号 # [A-Za-z]+ mark所有单词
;; 更快捷的forward"非矩形"复制: multiple cursors加一列光标，然后M-@ mark, 再然后C-M-f => M-w 复制 => 黏贴的地方必须要提前预留同样多行才能黏贴进去,不同于矩形的复制的黏贴,不需要多预留多行出来给黏贴使用
(defun reg-mark ()
  "正则选中多行编辑"
  (interactive)
  (call-interactively #'mc/mark-all-in-region-regexp))

;;   .        any character (but newline)
;;   *        previous character or group, repeated 0 or more time
;;   +        previous character or group, repeated 1 or more time
;;   ?        previous character or group, repeated 0 or 1 time
;;   ^        start of line
;;   $        end of line
;;   [...]    any character between brackets
;;   [^..]    any character not in the brackets
;;   [a-z]    any character between a and z
;;   \        prevents interpretation of following special char
;;   \|       or
;;   \w       word constituent
;;   \b       word boundary
;;   \sc      character with c syntax (e.g. \s- for whitespace char)
;;   \( \)    start/end of group
;;   \&lt; \&gt;    start/end of word (faulty rendering: backslash + less-than and backslash + greater-than)
;;   \_< \_>  start/end of symbol
;;   \` \'    start/end of buffer/string
;;   \1       string matched by the first group
;;   \n       string matched by the nth group
;;   \{3\}    previous character or group, repeated 3 times
;;   \{3,\}   previous character or group, repeated 3 or more times
;;   \{3,6\}  previous character or group, repeated 3 to 6 times
;;   \=       match succeeds if it is located at point

;;-;  [:digit:]  a digit, same as [0-9]
;;-;  [:alpha:]  a letter (an alphabetic character)
;;-;  [:alnum:]  a letter or a digit (an alphanumeric character)
;;-;  [:upper:]  a letter in uppercase
;;-;  [:lower:]  a letter in lowercase
;;-;  [:graph:]  a visible character
;;-;  [:print:]  a visible character plus the space character
;;-;  [:space:]  a whitespace character, as defined by the syntax table, but typically [ \t\r\n\v\f], which includes the newline character
;;-;  [:blank:]  a space or tab character
;;-;  [:xdigit:] an hexadecimal digit
;;-;  [:cntrl:]  a control character
;;-;  [:ascii:]  an ascii character
;;-;  [:nonascii:]  any non ascii character

;; 正则匹配: <*>*<*>
(defvar re-<> "\\(.*\\)<\\(.*\\)>\\(.*\\)<\\(.*\\)>\\(.*\\)")

;; 正则匹配pom的配置文件
(defvar re-pom "\\(.*\\)groupId\\(.*\\)\\|\\(.*\\)artifactId\\(.*\\)\\|\\(.*\\)version\\(.*\\)")

(provide 'jim-elisp-regexp)
