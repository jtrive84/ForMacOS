
;Set autofill mode
(setq-default auto-fill-hook 'do-auto-fill)

;Set Text mode as the default major mode.
(setq-default major-mode 'text-mode)

(global-linum-mode 1)
(setq linum-format "%4d \u2502 ")
(blink-cursor-mode t)

(setq-default tab-width 4)
(setq-default fill-column-indicator 80)
(setq make-backup-files nil)
(load-theme 'tango-dark)

