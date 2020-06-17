(add-to-list 'default-frame-alist
             '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist
             '(ns-appearance . dark))

(global-auto-revert-mode t)

(add-hook 'org-mode-hook #'auto-fill-mode)

(defun +org*update-cookies ()
  (when (and buffer-file-name (file-exists-p buffer-file-name))
    (let (org-hierarchical-todo-statistics)
      (org-update-parent-todo-statistics))))

(advice-add #'+org|update-cookies :override #'+org*update-cookies)

(add-hook! 'org-mode-hook (company-mode -1))
(add-hook! 'org-capture-mode-hook (company-mode -1))

; Set tab width to 2 for all buffers
(setq-default tab-width 2)

; Use 2 spaces instead of a tab.
(setq-default tab-width 2 indent-tabs-mode nil)

; Indentation cannot insert tabs.
(setq-default indent-tabs-mode nil)

(setq
 doom-font (font-spec :family "Hack" :size 16)
 doom-big-font (font-spec :family "Hack" :size 20)

 dart-format-on-save t
 js-indent-level 2
 coffee-tab-width 2
 python-indent 2
 css-indent-offset 2
 web-mode-markup-indent-offset 2
 web-mode-code-indent-offset 2
 web-mode-css-indent-offset 2
 typescript-indent-level 2
 json-reformat:indent-width 2
 prettier-js-args '("--single-quote")
 projectile-project-search-path '("~/pro/")
 dired-dwim-target t
 +doom-dashboard-banner-file (expand-file-name "logo.png" doom-private-dir))

(add-hook! reason-mode
  (add-hook 'before-save-hook #'refmt-before-save nil t))

(add-hook!
 js2-mode 'prettier-js-mode
 (add-hook 'before-save-hook #'refmt-before-save nil t))

(map! :ne "M-/" #'comment-or-uncomment-region)
(map! :ne "SPC / r" #'deadgrep)
(map! :ne "SPC n b" #'org-brain-visualize)

; Increment / Decrement numbers

(global-set-key (kbd "C-=") 'evil-numbers/inc-at-pt)
(global-set-key (kbd "C--") 'evil-numbers/dec-at-pt)
(define-key evil-normal-state-map (kbd "C-=") 'evil-numbers/inc-at-pt)
(define-key evil-normal-state-map (kbd "C--") 'evil-numbers/dec-at-pt)

;; (def-package! parinfer ; to configure it
;;   :bind (("C-," . parinfer-toggle-mode)
;;          ("<tab>" . parinfer-smart-tab:dwim-right)
;;          ("S-<tab>" . parinfer-smart-tab:dwim-left))
;;   :hook ((clojure-mode emacs-lisp-mode common-lisp-mode lisp-mode) . parinfer-mode)
;;   :config (setq parinfer-extensions '(defaults pretty-parens evil paredit)))

(after! ruby
  (add-to-list 'hs-special-modes-alist
               `(ruby-mode
                 ,(rx (or "def" "class" "module" "do" "{" "[")) ; Block start
                 ,(rx (or "}" "]" "end"))                       ; Block end
                 ,(rx (or "#" "=begin"))                        ; Comment start
                 ruby-forward-sexp nil)))

(after! web-mode
  (add-to-list 'auto-mode-alist '("\\.njk\\'" . web-mode)))

(defun +data-hideshow-forward-sexp (arg)
  (let ((start (current-indentation)))
    (forward-line)
    (unless (= start (current-indentation))
      (require 'evil-indent-plus)
      (let ((range (evil-indent-plus--same-indent-range)))
        (goto-char (cadr range))
        (end-of-line)))))

(add-to-list 'hs-special-modes-alist '(yaml-mode "\\s-*\\_<\\(?:[^:]+\\)\\_>" "" "#" +data-hideshow-forward-sexp nil))

(remove-hook 'enh-ruby-mode-hook #'+ruby|init-robe)

(setq +magit-hub-features t)

(require 'calendar)
(require 'russian-holidays)
(setq calendar-holidays russian-holidays)
(setq calendar-holidays (append calendar-holidays russian-holidays))

                                        ; pdf-tools
                                        ; When using evil-mode and pdf-tools and looking at a zoomed PDF, it will blink,
                                        ; because the cursor blinks. This configuration disables this whilst retaining the
                                        ; blinking cursor in other modes.

(evil-set-initial-state 'pdf-view-mode 'emacs)
(add-hook 'pdf-view-mode-hook
          (lambda ()
            (set (make-local-variable 'evil-emacs-state-cursor) (list nil))))


                                        ; org-mode configuration
(setq
 org-directory "~/Documents/org/"
 org-agenda-skip-scheduled-if-done t
 org-ellipsis " ▾ "
 org-bullets-bullet-list '("·")
 org-tags-column -80
 org-log-done 'time
 org-refile-targets (quote ((nil :maxlevel . 1)))
 org-capture-templates '(("x" "Note" entry
                          (file+olp+datetree "journal.org")
                          "**** [ ] %U %?" :prepend t :kill-buffer t)
                         ("t" "Task" entry
                          (file+headline "tasks.org" "Inbox")
                          "* [ ] %?\n%i" :prepend t :kill-buffer t))
 +org-capture-todo-file "tasks.org"
 org-super-agenda-groups '((:name "Today"
                                  :time-grid t
                                  :scheduled today)
                           (:name "Due today"
                                  :deadline today)
                           (:name "Important"
                                  :priority "A")
                           (:name "Overdue"
                                  :deadline past)
                           (:name "Due soon"
                                  :deadline future)
                           (:name "Big Outcomes"
                                  :tag "bo")))
                                        ; languages for org-babel support
(org-babel-do-load-languages
 'org-babel-load-languages
 '(
   (shell . t)
   (js . t)
   (ruby . t)
   ))

(add-hook 'org-mode-hook 'auto-fill-mode)
(add-hook 'org-mode-hook 'flyspell-mode)

(defun set-org-agenda-files ()
  "Set different org-files to be used in `org-agenda`."
  (setq org-agenda-files (list (concat org-directory "things.org")
                               (concat org-directory "inbox.org")
                               (concat org-directory "reference.org")
                               (concat org-directory "snikulincal.org")
                               (concat org-directory "zencarcal.org")
                               (concat org-directory "grishinroboticscal.org")
                               )))

(set-org-agenda-files)

(global-set-key "\C-cl" 'org-store-link)

(defun things ()
  "Open main 'org-mode' file and start 'org-agenda' for today."
  (interactive)
  (find-file (concat org-directory "things.org"))
  (set-org-agenda-files)
  (org-agenda-list)
  (org-agenda-day-view)
  (shrink-window-if-larger-than-buffer)
  (other-window 1))

(setq org-duration-format 'h:mm)

(after! org
  (set-face-attribute 'org-link nil
                      :weight 'normal
                      :background nil)
  (set-face-attribute 'org-code nil
                      :foreground "#a9a1e1"
                      :background nil)
  (set-face-attribute 'org-date nil
                      :foreground "#5B6268"
                      :background nil)
  (set-face-attribute 'org-level-1 nil
                      :foreground "steelblue2"
                      :background nil
                      :height 1.2
                      :weight 'normal)
  (set-face-attribute 'org-level-2 nil
                      :foreground "slategray2"
                      :background nil
                      :height 1.0
                      :weight 'normal)
  (set-face-attribute 'org-level-3 nil
                      :foreground "SkyBlue2"
                      :background nil
                      :height 1.0
                      :weight 'normal)
  (set-face-attribute 'org-level-4 nil
                      :foreground "DodgerBlue2"
                      :background nil
                      :height 1.0
                      :weight 'normal)
  (set-face-attribute 'org-level-5 nil
                      :weight 'normal)
  (set-face-attribute 'org-level-6 nil
                      :weight 'normal)
  (set-face-attribute 'org-document-title nil
                      :foreground "SlateGray1"
                      :background nil
                      :height 1.75
                      :weight 'bold)
  (setq org-fancy-priorities-list '("⚡" "⬆" "⬇" "☕")))


(set-popup-rule! "^\\*Org Agenda" :side 'bottom :size 0.90 :select t :ttl nil)
(set-popup-rule! "^CAPTURE.*\\.org$" :side 'bottom :size 0.90 :select t :ttl nil)
(set-popup-rule! "^\\*org-brain" :side 'right :size 1.00 :select t :ttl nil)

                                        ; Generate passwords through pwgen.
                                        ; Thanks to @branch14 of 200ok fame for the function!

(defun generate-password-non-interactive ()
  (string-trim (shell-command-to-string "pwgen -A 24")))

(defun generate-password ()
  "Generates and inserts a new password"
  (interactive)
  (insert
   (shell-command-to-string
    (concat "pwgen -A " (read-string "Length: " "24") " 1"))))

                                        ; Open passwords file

(defun passwords ()
  "Open main 'passwords' file."
  (interactive)
  (find-file (concat org-directory "vault/primary.org.gpg")))

                                        ; Mail confgiguration
                                        ; Authentication

(require 'org-mu4e)                                        ; Tell Emacs where to find the encrypted .authinfo file.

(setq auth-sources
      '((:source "~/.authinfo.gpg")))

(setq send-mail-function 'smtpmail-send-it)

;; Default account on startup
(setq user-full-name  "Sergey Nikulin"
      mu4e-sent-folder "/gmail/[Gmail].Sent Mail"
      mu4e-drafts-folder "/gmail/[Gmail].Drafts"
      mu4e-trash-folder "/gmail/[Gmail].Trash")

(setq smtpmail-debug-info t
      message-kill-buffer-on-exit t
      ;; Custom script to run offlineimap in parallel for multiple
      ;; accounts as discussed here:
      ;; http://www.offlineimap.org/configuration/2016/01/29/why-i-m-not-using-maxconnctions.html
      ;; This halves the time for checking mails for 4 accounts for me
      ;; (when nothing has to be synched anyway)
      mu4e-get-mail-command "mailsync"
      mu4e-attachment-dir "~/Documents/org/files/inbox")

(setq mu4e-maildir "~/.local/share/mail/")

;; show full addresses in view message (instead of just names)
;; toggle per name with M-RET
(setq mu4e-view-show-addresses t)

;; Do not show related messages by default (toggle with =W= works
;; anyway)
(setq mu4e-headers-include-related nil)

;; Alternatives are the following, however in first tests they
;; show inferior results
;; (setq mu4e-html2text-command "textutil -stdin -format html -convert txt -stdout")
;; (setq mu4e-html2text-command "html2text -utf8 -width 72")
;; (setq mu4e-html2text-command "w3m -dump -T text/html")

(defvar my-mu4e-account-alist
  '(("gmail"
     (user-full-name  "Sergey Nikulin")
     (mu4e-compose-signature "Best wishes\nSergey Nikulin")
     (mu4e-compose-signature-auto-include t)
     (mu4e-sent-folder "/gmail/[Gmail].Sent Mail")
     (mu4e-drafts-folder "/gmail/[Gmail].Drafts")
     (mu4e-trash-folder "/gmail/[Gmail].Trash")
     (user-mail-address "snikulin@gmail.com")
     (smtpmail-default-smtp-server "smtp.gmail.com")
     (smtpmail-local-domain "gmail.com")
     (smtpmail-smtp-user "snikulin@gmail.com")
     (smtpmail-smtp-server "smtp.gmail.com")
     (smtpmail-stream-type starttls)
     (smtpmail-smtp-service 587))
    ("zencar"
     (mu4e-compose-signature-auto-include t)
     (user-full-name  "Sergey Nikulin")
     (mu4e-sent-folder "/zencar/[Gmail].Sent Mail")
     (mu4e-drafts-folder "/zencar/[Gmail].Drafts")
     (mu4e-trash-folder "/zencar/[Gmail].Trash")
     (user-mail-address "sn@zen.car")
     (smtpmail-default-smtp-server "smtp.gmail.com")
     (smtpmail-smtp-server "smtp.gmail.com")
     (smtpmail-local-domain "zen.car")
     (smtpmail-smtp-user "sn@zen.car")
     (smtpmail-stream-type starttls)
     (smtpmail-smtp-service 587))
    ("nikhacky"
     (mu4e-compose-signature-auto-include t)
     (user-full-name  "Sergey Nikulin")
     (mu4e-sent-folder "/nikhacky/Sent")
     (mu4e-drafts-folder "/nikhacky/Drafts")
     (mu4e-trash-folder "/nikhacky/Trash")
     (user-mail-address "nik@hacky.ru")
     (smtpmail-default-smtp-server "smtp.yandex.com")
     (smtpmail-smtp-server "smtp.yandex.com")
     (smtpmail-local-domain "hacky.ru")
     (smtpmail-smtp-user "nik@hacky.ru")
     (smtpmail-stream-type starttls)
     (smtpmail-smtp-service 587))
    ("nikulinhacky"
     (mu4e-compose-signature-auto-include t)
     (user-full-name  "Sergey Nikulin")
     (mu4e-sent-folder "/nikulinhacky/Sent")
     (mu4e-drafts-folder "/nikulinhacky/Drafts")
     (mu4e-trash-folder "/nikulinhacky/Trash")
     (user-mail-address "nikulin@hacky.ru")
     (smtpmail-default-smtp-server "smtp.yandex.com")
     (smtpmail-smtp-server "smtp.yandex.com")
     (smtpmail-local-domain "hacky.ru")
     (smtpmail-smtp-user "nikulin@hacky.ru")
     (smtpmail-stream-type starttls)
     (smtpmail-smtp-service 587))
    ("yandex"
     (mu4e-compose-signature-auto-include t)
     (user-full-name  "Sergey Nikulin")
     (mu4e-sent-folder "/yandex/Sent")
     (mu4e-drafts-folder "/yandex/Drafts")
     (mu4e-trash-folder "/yandex/Trash")
     (user-mail-address "nikulin-sn@yandex.ru")
     (smtpmail-default-smtp-server "smtp.yandex.com")
     (smtpmail-smtp-server "smtp.yandex.com")
     (smtpmail-local-domain "yandex.ru")
     (smtpmail-smtp-user "nikulin-sn@yandex.ru")
     (smtpmail-stream-type starttls)
     (smtpmail-smtp-service 587))
    ))

;; Whenever a new mail is to be composed, change all relevant
;; configuration variables to the respective account. This method is
;; taken from the MU4E documentation:
;; http://www.djcbsoftware.nl/code/mu/mu4e/Multiple-accounts.html#Multiple-accounts
(defun my-mu4e-set-account ()
  "Set the account for composing a message."
  (let* ((account
          (if mu4e-compose-parent-message
              (let ((maildir (mu4e-message-field mu4e-compose-parent-message :maildir)))
                (string-match "/\\(.*?\\)/" maildir)
                (match-string 1 maildir))
            (completing-read (format "Compose with account: (%s) "
                                     (mapconcat #'(lambda (var) (car var))
                                                my-mu4e-account-alist "/"))
                             (mapcar #'(lambda (var) (car var)) my-mu4e-account-alist)
                             nil t nil nil (caar my-mu4e-account-alist))))
         (account-vars (cdr (assoc account my-mu4e-account-alist))))
    (if account-vars
        (mapc #'(lambda (var)
                  (set (car var) (cadr var)))
              account-vars)
      (error "No email account found"))))


(add-hook 'mu4e-compose-pre-hook 'my-mu4e-set-account)
(add-hook 'mu4e-compose-mode-hook 'flyspell-mode)
(add-hook 'mu4e-compose-mode-hook (lambda ()
                                    (ispell-change-dictionary "russian")))


(setq mu4e-refile-folder
      (lambda (msg)
        (cond
         ((string-match "^/dispatched.*"
                        (mu4e-message-field msg :maildir))
          "/dispatched/Archive")
         ((string-match "^/zencar.*"
                        (mu4e-message-field msg :maildir))
          "/zencar/Archive")
         ((string-match "^/gmail.*"
                        (mu4e-message-field msg :maildir))
          "/gmail/Archive")
         ((string-match "^/nikhacky.*"
                        (mu4e-message-field msg :maildir))
          "/nikhacky/Archive")
         ((string-match "^/nikulinhacky.*"
                        (mu4e-message-field msg :maildir))
          "/nikulinhacky/Archive")
         ((string-match "^/yandex.*"
                        (mu4e-message-field msg :maildir))
          "/yandex/Archive")
         ;; everything else goes to /archive
         (t  "/archive"))))


(setq mu4e-trash-folder
      (lambda (msg)
        (cond
         ((string-match "^/dispatched.*"
                        (mu4e-message-field msg :maildir))
          "/dispatched/Trash")
         ((string-match "^/zencar.*"
                        (mu4e-message-field msg :maildir))
          "/zencar/[Gmail].Trash")
         ((string-match "^/gmail.*"
                        (mu4e-message-field msg :maildir))
          "/gmail/[Gmail].Trash")
         ((string-match "^/nikhacky.*"
                        (mu4e-message-field msg :maildir))
          "/nikhacky/Trash")
         ((string-match "^/nikulinhacky.*"
                        (mu4e-message-field msg :maildir))
          "/nikulinhacky/Trash")
         ((string-match "^/yandex.*"
                        (mu4e-message-field msg :maildir))
          "/yandex/Trash")
         ;; everything else goes to /trash
         (t  "/trash"))))

;; Empty the initial bookmark list
(setq mu4e-bookmarks '())

;; Re-define all standard bookmarks to not include the spam folders
;; for searches
(defvar d-spam "NOT (maildir:/dispatched/INBOX.spambucket OR maildir:/zencar/INBOX.spambucket OR maildir:/gmail/INBOX.spambucket OR maildir:/zhaw/\"Junk E-Mail\" OR maildir:/zhaw/\"Deleted Items\")")

(defvar inbox-folders (string-join '("maildir:/dispatched/INBOX"
                                     "maildir:/zencar/INBOX"
                                     "maildir:/gmail/INBOX"
                                     "maildir:/nikhacky/INBOX"
                                     "maildir:/nikulinhacky/INBOX"
                                     "maildir:/yandex/INBOX")
                                   " OR "))

(defvar draft-folders (string-join '("maildir:/dispatched/Drafts"
                                     "maildir:/zencar/[Gmail].Drafts"
                                     "maildir:/gmail/[Gmail].Drafts"
                                     "maildir:/nikhacky/INBOX.Drafts"
                                     "maildir:/nikulinhacky/Drafts"
                                     "maildir:/yandex/Drafts")
                                   " OR "))

(defvar spam-folders (string-join '("maildir:/dispatched/Spam"
                                    "maildir:/zencar/[Gmail].Spam"
                                    "maildir:/gmail/[Gmail].Spam"
                                    "maildir:/nikhacky/Spam"
                                    "maildir:/nikulinhacky/Spam"
                                    "maildir:/yandex/Spam")
                                  " OR "))

(add-to-list 'mu4e-bookmarks
             '((concat d-spam " AND date:today..now")                  "Today's messages"     ?t))
(add-to-list 'mu4e-bookmarks
             '((concat d-spam " AND date:7d..now")                     "Last 7 days"          ?w))
(add-to-list 'mu4e-bookmarks
             '((concat d-spam " AND flag:flagged")                     "Flagged"              ?f))
(add-to-list 'mu4e-bookmarks
             '((concat d-spam " AND mime:image/*")                     "Messages with images" ?p))
(add-to-list 'mu4e-bookmarks
             '(spam-folders "All spambuckets"     ?S))
(add-to-list 'mu4e-bookmarks
             '(draft-folders "All drafts"     ?d))
(add-to-list 'mu4e-bookmarks
             '(inbox-folders "All inbox mails"     ?i))
(add-to-list 'mu4e-bookmarks
             '((concat d-spam " AND (flag:unread OR flag:flagged) AND NOT flag:trashed")
               "Unread messages"      ?u))

                                        ; For mail completion, only consider emails that have been seen in the last 6 months. This gets rid of legacy mail addresses of people.

(setq mu4e-compose-complete-only-after (format-time-string
                                        "%Y-%m-%d"
                                        (time-subtract (current-time) (days-to-time 150))))

                                        ; HTML Mails
(require 'mu4e)
(require 'mu4e-contrib)
(setq mu4e-html2text-command 'mu4e-shr2text)
;;(setq mu4e-html2text-command "iconv -c -t utf-8 | pandoc -f html -t plain")
(add-to-list 'mu4e-view-actions '("ViewInBrowser" . mu4e-action-view-in-browser) t)
(setq mu4e-view-html-plaintext-ratio-heuristic  most-positive-fixnum)

                                        ; Setting Format=Flowed for non-text-based mail clients which don’t respect actual formatting, but let the text “flow” as they please.

(setq mu4e-compose-format-flowed t)

                                        ; Updating mails:
                                        ;    Periodic - every 15 minutes
                                        ;    Happening in the background

                                        ; Note: There’s no notifications, because that’s only distracting.

(setq mu4e-update-interval (* 5 60))
(setq mu4e-index-update-in-background t)

                                        ; Automatic line breaks when reading mail

(add-hook 'mu4e-view-mode-hook 'visual-line-mode)

                                        ; Do not reply to self

(setq mu4e-compose-dont-reply-to-self t)

;(add-to-list 'mu4e-user-mail-address-list "snikulin@gmail.com")
;(add-to-list 'mu4e-user-mail-address-list "sn@zen.car")
;(add-to-list 'mu4e-user-mail-address-list "nik@hacky.ru")
;(add-to-list 'mu4e-user-mail-address-list "nikulin@hacky.ru")
;(add-to-list 'mu4e-user-mail-address-list "nikulin-sn@yandex.ru")

(require 'org-gcal)
(setq org-gcal-client-id "868058794491-idcb2gvff115t7r1gf2jvru8348mpsgk.apps.googleusercontent.com"
      org-gcal-client-secret "Hj5VAGOTOOEL9xaLSjb_XooJ"
      org-gcal-file-alist '(("snikulin@gmail.com" .  "~/Documents/org/snikulincal.org")
                            ("sn@zen.car" . "~/Documents/org/zencarcal.org")
                            ("sergey@grishinrobotics.com" . "~/Documents/org/grishinroboticscal.org")
                            ))
