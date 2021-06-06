;;; dart-import-sorter-mode.el --- Minor mode for Dart which runs import_sorter on save  -*- lexical-binding: t -*-

;; Copyright (C) 2021 Peter Stuart

;; Author: Peter Stuart <peter@peterstuart.org>
;; Maintainer: Peter Stuart <peter@peterstuart.org>
;; Created: 6 Jun 2021
;; URL: https://github.com/peterstuart/dart-import-sorter-mode
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1") (dart-mode "1.0.5"))

;;; Commentary:

;; Requires https://pub.dev/packages/import_sorter to be installed as
;; a dev dependency in the Dart project.

;;; Code:

(define-minor-mode dart-import-sorter-mode
  "Toggle Dart Import Sorter mode."
  nil
  :group 'dart-import-sorter

  (if dart-import-sorter-mode
      (add-hook 'after-save-hook #'dart-import-sorter--sort nil t)
    (remove-hook 'after-save-hook #'dart-import-sorter--sort t)))

(add-hook 'dart-mode-hook 'dart-import-sorter-mode)

(defun dart-import-sorter--sort ()
  "Run import_sorter on the current file or directory."
  (interactive)
  (let* ((path (or buffer-file-name "."))
	 (command (dart-import-sorter--pub (format "run import_sorter:main %s" path))))
    (if command
	(progn (shell-command command)
	       (revert-buffer nil t t))
      (message "Cannot sort imports: neither 'flutter' nor 'pub' is present."))))

(defun dart-import-sorter--pub (TASK)
  "Return a string which can be used to run TASK with pub.

Use `flutter pub' if flutter is available, or `pub' directly if
it is not."
  (let ((command
	 (cond ((executable-find "flutter")
		"flutter pub")
	       ((executable-find "pub")
		"pub")
	       (t
		nil))))
    (if command
	(format "%s %s" command TASK)
      nil)))

(provide 'dart-import-sorter-mode)

;;; dart-import-sorter-mode.el ends here
