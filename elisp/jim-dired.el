;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Dired-Deletion.html

;; 批量删除文件: d 选中 + x批量删除选中
;;d : Flag this file for deletion (dired-flag-file-deletion).
;;u : Remove the deletion flag (dired-unmark).
;;<DEL> : Move point to previous line and remove the deletion flag on that line (dired-unmark-backward).
;;x : Delete files flagged for deletion (dired-do-flagged-delete).
;;
(provide 'jim-dired)
