;;; flycheck-pyre.el --- Support Pyre in flycheck -*- lexical-binding: t -*-

;; Copyright (C) 2018 Vyacheslav Linnik <vyacheslav.linnik@gmail.com>
;; License: MIT
;;
;; Author: Vyacheslav Linnik <vyacheslav.linnik@gmail.com>
;; Version: 2018.09.03
;; Package-Requires: ((emacs "24") (flycheck "29"))

;;; Commentary:

;; This package adds support for Pyre type checker to flycheck.
;; To use it, add to your init.el:

;; (require 'flycheck-pyre)
;; (add-hook 'python-mode-hook 'flycheck-mode)

;;; Code:
(require 'flycheck)
(require 'cl-lib)
(require 'json)

(flycheck-def-args-var flycheck-pyre-args python-pyre)

(defvar flycheck-pyre-wrapper
  (executable-find
   (concat (file-name-directory
            (or load-file-name buffer-file-name))
           "bin/pyrewrapper.sh")))

(defun flycheck-pyre-parse-errors (output checker buffer)
  "Decode pyre json OUTPUT errors using CHECKER for specific BUFFER."
  (let* ((filepath (buffer-file-name buffer))
         (parsed (flycheck-pyre-parse-error-data output))
         (filtered (flycheck-pyre-filter-by-filepath parsed filepath)))
    (flycheck-pyre-decode-error-data filtered checker buffer)))

(defun flycheck-pyre-parse-error-data (data)
  "Parse Pyre raw DATA into a list."
  (let* ((json-array-type 'list)
         (mapdata (mapcar
                   'flycheck-pyre-read-json
                   (split-string data "\n"))))
    (append (car mapdata) (car (cdr mapdata)))))

(defun flycheck-pyre-read-json (str)
  "Read json from the STR."
  (condition-case nil
      (json-read-from-string str)
    (error nil)))

(defun flycheck-pyre-filter-by-filepath(pyre-errors filepath)
  "Filter PYRE-ERRORS by specific FILEPATH."
  (cl-remove-if-not
   (lambda (pyre-error)
     (string-match-p
      (flycheck-pyre-decode-filepath pyre-error) filepath)) pyre-errors))

(defun flycheck-pyre-decode-error-data (pyre-errors checker buffer)
  "Build list of flycheck errors from PYRE-ERRORS list by a CHECKER for a BUFFER."
  (mapcar (lambda (x) (flycheck-pyre-decode-pyre-error x checker buffer)) pyre-errors))

(defun flycheck-pyre-decode-filepath (pyre-error)
  "Decode filepath from the PYRE-ERROR."
  (cdr (assoc 'path pyre-error)))

(defun flycheck-pyre-decode-pyre-error (pyre-error checker buffer)
  "Build flycheck error structure from PYRE-ERROR of CHECKER for a BUFFER."
  (flycheck-error-new
   :checker checker
   :buffer buffer
   :level 'error
   :filename (cdr (assoc 'path pyre-error))
   :line (cdr (assoc 'line pyre-error))
   :column (cdr (assoc 'column pyre-error))
   :message (cdr (assoc 'description pyre-error))))

(defun flycheck-pyre-directory (&optional checker)
  "Find the directory in which CHECKER should run Pyre."
  (locate-dominating-file (buffer-file-name) ".pyre_configuration"))

(flycheck-define-command-checker 'python-pyre
  "Pyre syntax checker.

Customize `flycheck-pyre-args` to add specific args to default
executable."

  :command `(,flycheck-pyre-wrapper
             "pyre" "--output=json"
             (eval flycheck-pyre-args))
  :working-directory 'flycheck-pyre-directory
  :predicate 'flycheck-pyre-directory
  :error-parser 'flycheck-pyre-parse-errors
  :modes 'python-mode)

;;;###autoload
(defun flycheck-pyre-setup ()
  "Setup Flycheck Pyre."
  (interactive)
  (add-to-list 'flycheck-checkers 'python-pyre))

(provide 'flycheck-pyre)
;;; flycheck-pyre.el ends here
