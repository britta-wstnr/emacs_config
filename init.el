;; init.el --- Emacs configuration

;; todo:
;; buffer list should open in same window, magits should open in same window
;; how can i make dired ask in which window to open a file when using o
;; shackle for shell or magit?

;; ----------------
;; INSTALL PACKAGES
;; ----------------
(require 'package)

(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(defvar myPackages
  '(better-defaults
    ein  ;; thats for ipython notebook
    material-theme
    flycheck  ;; real-time syntax checking for elpy
    multiple-cursors
    shackle  ;; control stupid pop up behaviours
    iedit  ;; manipulate several occurrences of same name in buffer
    ace-window  ;; to switch between windows
    smartparens  
    org
    winner ;; to switch between window configurations
    ))  
    
(mapc #'(lambda (package)
    (unless (package-installed-p package)
      (package-install package)))
      myPackages)


;; --------------------
;; CUSTOMIZE EMACS FACE
;; --------------------
(setq inhibit-startup-message t) ;; hide the startup message
(load-theme 'material t) ;; load material theme
(global-linum-mode t) ;; enable line numbers globally
(set-face-attribute 'linum nil :height 100)  ;; make sure they stay the same height
(add-to-list 'default-frame-alist
	     '(fullscreen . maximized))  ;; start with maximized window
(desktop-save-mode 1)  ;; restore last session
(tool-bar-mode -1)  ;;  suppressing tool bar
(menu-bar-mode -1)  ;; suppress menu bar
(toggle-scroll-bar -1)  ;; suppresses scroll bar
(fset 'yes-or-no-p 'y-or-n-p)  ;; change all required  yes/no answers to y/n


;; fill column: marker @ line 79 (python mode)
(add-to-list 'load-path (concat user-emacs-directory "/elpa/fillcolumnindicator/"))
(require 'fill-column-indicator)
(setq fci-rule-column 79)
(setq fci-rule-color "dim gray")
(add-hook 'python-mode-hook 'fci-mode) ;; turn on for python files
(add-hook 'matlab-mode-hook 'fci-mode) ;; also for MATLAB files

;; get the current path into the mode line top bar
(setq frame-title-format
      (list (format "emacs    " )
	    '(buffer-file-name "%f" (dired-directory dired-directory "%b"))
	    '("    May the Force be with you.")))  ;; gimmicks :)

;; highlight code tags in python
(add-hook 'python-mode-hook
	  (lambda ()
		  (font-lock-add-keywords nil
		  '(("\\<\\(FIXME\\|BUG\\|TODO\\|XXX\\)" 1 font-lock-warning-face t)))))


;; -----------------------------
;; MANAGE EMACS GLOBAL BEHAVIOUR
;; -----------------------------
(global-set-key (kbd "S-C-<up>") 'shrink-window)
(global-set-key (kbd "S-C-<down>") 'enlarge-window)
(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
;; server mode
(if (not server-mode)
    (server-start nil 1))
;; fix the stupid SHELL behaviour - open shell in same window
(push (cons "\\*shell\\*" display-buffer--same-window-action) display-buffer-alist)
;; set switch windows with ace shortcut
(global-set-key (kbd "C-x o") 'ace-window)
;; make sure that mistyping C-x u doesn't lead to annoying pop-ups (don't care about upcase-region)
(global-set-key (kbd "C-x C-u") 'undo)
;; move forward wordwise: stop at beginning of word
(global-set-key (kbd "M-f") (lambda() (interactive) (forward-word) (forward-char)))
(winner-mode 1)  ;; turn winner mode on by default
(global-set-key (kbd "C-x M-;") 'comment-kill)
(global-set-key (kbd "C-;") 'iedit-mode)

		
;; ----------------------------------------------
;; COSTUMIZE ELPY (installed manually in Scratch)
;; ----------------------------------------------
(elpy-enable)
(elpy-use-ipython)
(delete `elpy-module-highlight-indentation elpy-modules)  ;; stupid ind. highlighting
(highlight-indentation-mode -1)  ;; shut that off on all layers


;; -------------------------------------------------------------------------
;; SET SHACKLE RULES for ipython notebooks to open everything in same window
;; -------------------------------------------------------------------------
(setq shackle-rules '(("\\ein: .+?\\.ipynb\\*\\'" :regexp t :same t)
		      ("\\ein:notebooklist .+?\\:8888\\*\\'" :regexp t :same t)))
(shackle-mode)


;; --------
;; ACE-JUMP
;; --------
(add-to-list 'load-path (concat user-emacs-directory "/elpa/acejump/"))
(autoload
  'ace-jump-mode
  "ace-jump-mode"
  "Emacs quick move minor mode"
  t)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)


;; --------------------------------------
;; MULTIPLE CURSORS -- MC and ACE JUMP MC
;; ---------------------------------------
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C-<") 'mc/mark-next-like-this)
(global-set-key (kbd "C->") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(global-set-key (kbd "C-+") 'ace-mc-add-multiple-cursors)


;; -------------------------
;; PYTHON MODE modifications
;; -------------------------
(add-hook 'elpy-mode-hook
	  (lambda ()
	    (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)))
;; Set up flycheck (instead of elpy's flymake)
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))  ;; automatically load when python file
;; enable smart parentheses 
(add-hook 'elpy-mode-hook #'smartparens-mode)


;; ------------------------
;; LATEX MODE modifications
;; ------------------------
(add-hook 'LaTeX-mode-hook #'smartparens-mode)
(add-hook 'LaTeX-mode-hook 'TeX-PDF-mode)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq TeX-save-query nil)


;; -----
;; MAGIT
;; -----
(setq magit-save-repository-buffers 'dontask)  ;; buffers will be saved autom. when starting magit
(global-set-key (kbd "C-c m") 'magit-status)  ;; M-x magit-status is cumbersome
;; force C-c m to open in same window, but not the rest:
(setq magit-display-buffer-function
      (lambda (buffer)
        (display-buffer
         buffer (if (and (derived-mode-p 'magit-mode)
                         (memq (with-current-buffer buffer major-mode)
                               '(magit-process-mode
                                 magit-revision-mode
                                 ; magit-diff-mode
                                 magit-stash-mode
                                 magit-status-mode)))
                    nil
                  '(display-buffer-same-window)))))


;; ----------------------
;; ORG MODE modifications
;; ----------------------
(setq org-agenda-window-setup 'current-window)
(setq org-todo-keywords
      '((sequence "TODO" "REMEMBER" "IN-PROG" "WAITING" "|"  "CANCELLED" "DONE")))
(setq org-log-done 'time)
(setq org-ellipsis " . ")
(setq-default org-display-custom-times t)
(setq org-time-stamp-custom-formats '("<%a %d-%m-%Y>" . "<%a %d-%m-%Y %H:%M> "))
(setq system-time-locale "C")
;; agenda:
(global-set-key (kbd "C-c a") 'org-agenda)
(setq org-agenda-files
      (quote
       ("~/Dokumente/projects.org")))
(setq org-deadline-warning-days 10)
(setq org-agenda-prefix-format " %t %s ")
;; clocking:
(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)
;; archive all DONE items at once:
(defun org-archive-done-tasks ()
  (interactive)
  (org-map-entries
   (lambda ()
     (org-archive-subtree)
     (setq org-map-continue-from (outline-previous-heading)))
   "/DONE" 'agenda))
;; archive all CANCELLED items at once:
(defun org-archive-cancelled-tasks ()
  (interactive)
  (org-map-entries
   (lambda ()
     (org-archive-subtree)
     (setq org-map-continue-from (outline-previous-heading)))
   "/CANCELLED" 'agenda))

;; -----------------
;; Emacs MATLAB mode
;; -----------------
(add-to-list 'load-path (concat user-emacs-directory "/elpa/matlab-emacs")
(load-library "matlab-load")
(add-to-list 'auto-mode-alist '("\\.m\\'" . matlab-mode))  ;; MATLAB files evoke Matlab mode
(setq matlab-indent-function t)
(setq matlab-shell-command "matlab")
(add-hook 'matlab-mode-hook
	  (lambda ()
	    (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)))
(setq matlab-auto-fill nil)


;; --------------------------------------------------------
;; all below here was AUTOMATICALLY added by Custom for me:
;; --------------------------------------------------------
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(elpy-rpc-backend "rope")
 '(matlab-auto-fill nil)
 '(matlab-shell-command-switches (quote ("-nodesktop -nosplash")))
 '(package-selected-packages
   (quote
    (auctex markdown-mode ace-mc multiple-cursors flymd magit material-theme elpy better-defaults))))


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
