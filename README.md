# flycheck-pyre 

[![MELPA](https://melpa.org/packages/flycheck-pyre-badge.svg)](https://melpa.org/#/flycheck-pyre)

Flycheck support for the Pyre type checker

## Setup

Install pyre and watchman

```
pip install pyre-check
brew install watchman
```

Init Pyre and startup a background daemon.
For more information visit [Pyre's documentation](https://pyre-check.org/docs/overview.html)

```bash
pyre init
pyre check
pyre start
```

Add to your `.init.el`:

```elisp
(require 'flycheck-pyre)
(add-hook 'python-mode-hook 'flycheck-mode)
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-pyre-setup))
```
