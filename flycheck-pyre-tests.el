;;; flycheck-pyre-tests.el --- Support Pyre in flycheck -*- lexical-binding: t -*-

;; Copyright (C) 2018 Vyacheslav Linnik <vyacheslav.linnik@gmail.com>
;; License: MIT
;;
;; Author: Vyacheslav Linnik <vyacheslav.linnik@gmail.com>

;;; Commentary:
;; Expected error format
;; {
;;     "line": 76,
;;     "column": 31,
;;     "path": "module/example.py",
;;     "code": 16,
;;     "name": "Undefined attribute",
;;     "description": "Undefined attribute [16]: Optional type has no attribute `__getitem__`.",
;;     "inference": {},
;;     "do_not_check": false,
;;     "external_to_project_root": false,
;;     "external_to_source_root": false
;; }

;;; Code:
(require 'flycheck-pyre)
(require 'json)

(ert-deftest test-pyre-parse-warning ()
  "Test that the warning types are parsed correctly"
  (let* ((json-array-type 'list)
         (data (json-read-from-string "{\"path\":\"test_pyre_module.py\"}")))
    (should (equal (flycheck-pyre-decode-filepath data) "test_pyre_module.py"))))

(ert-deftest test-filter-by-buffer-name()
  "Test that we can filter out errors by buffer name
   with an absolute path in it."
  (let* ((checker nil) (buffer nil)
         (buffer-name "/Users/author/workspace/myproject/module/example.py")
         (parsed (flycheck-pyre-parse-error-data pyre-errors))
         (filtered (flycheck-pyre-filter-by-filepath parsed buffer-name))
         (decoded (flycheck-pyre-decode-error-data filtered checker buffer))
         (item (car decoded)))
    (should (= 2 (length parsed)))
    (should (= 1 (length filtered)))
    (should (string= (flycheck-error-filename item) "module/example.py"))))

(ert-deftest test-decoded-error-content()
  "Test whether content of decoded error is matching our expectations."
  (let* ((checker nil) (buffer nil)
         (buffer-name "/Users/author/workspace/myproject/module/example.py")
         (parsed (flycheck-pyre-parse-error-data pyre-errors))
         (filtered (flycheck-pyre-filter-by-filepath parsed buffer-name))
         (decoded (flycheck-pyre-decode-error-data filtered checker buffer))
         (item (car decoded)))
    (should (= 76 (flycheck-error-line item)))
    (should (= 31 (flycheck-error-column item)))
    (should (string= (flycheck-error-filename item) "module/example.py"))
    (should (string= (flycheck-error-message item) "Undefined attribute [16]: Optional type has no attribute `__getitem__`."))))


(ert-deftest test-pyre-stderr()
  "Test whether parsing invalid Pyre output raises a user error."
  (should-error (flycheck-pyre-parse-error-data pyre-stderr) :type 'user-error))

(defconst pyre-errors "[\
  {\
    \"line\": 76,\
    \"column\": 31,\
    \"path\": \"module/example.py\",\
    \"code\": 16,\
    \"name\": \"Undefined attribute\",\
    \"description\": \"Undefined attribute [16]: Optional type has no attribute `__getitem__`.\",\
    \"inference\": {},\
    \"do_not_check\": false,\
    \"external_to_project_root\": false,\
    \"external_to_source_root\": false\
  },\
  {\
    \"line\": 5,\
    \"column\": 0,\
    \"path\": \"module/other.py\",\
    \"code\": 21,\
    \"name\": \"Undefined import\",\
    \"description\": \"Undefined import [21]: Could not find a module corresponding to import `graphviz`.\",\
    \"inference\": {},\
    \"do_not_check\": false,\
    \"external_to_project_root\": false,\
    \"external_to_source_root\": false\
  }\
]")

(defconst pyre-stderr "2018-09-12 01:23:30,608 DEBUG No configuration found at `.pyre_configuration.local`. 2018-09-12 01:23:30,609 DEBUG Reading configuration `.pyre_configuration`... 2018-09-12 01:23:30,609 DEBUG Found source_directories: `.` 2018-09-12 01:23:30,609 ERROR Invalid configuration: Binary at `/usr/local/bin/pyre.bin` does not exist.")

;;; flycheck-pyre-tests.el ends here
