;;; mu4e-filters.el --- Narrow and search filters for mu4e email
;; Author: Daniel Nemenyi <daniel@pompo.co>
;; Keywords: mu4e
;; Version: 0.1
;; URL: https://github.com/danielnemenyi/mu4e-filters
;; Package-Requires: ((emacs "28.1") (mu4e "1.6.10"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file LICENSE.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

(require 'cal-iso) ; Needed for mu4e-filter-by-date

(defconst mu4e-filter-version "0.1")

(defgroup mu4e-filters nil
  "Settings for message view filters."
  :group 'mu4e)

(add-hook 'mu4e-headers-mode-hook
          (lambda () (local-set-key (kbd ",") 'mu4e-filters)))

(add-hook 'mu4e-view-mode-hook
          (lambda () (local-set-key (kbd ",") 'mu4e-filters)))

(defun mu4e-filters ()
  "Offer various mu4e message view filters.

This interactive function narrows the current mu4e message view
unless it is called with a predicate (`C-u'), in which case it
performs a global search instead.

The list of enabled filters is set by the variable
`mu4e-filters-enabled'."
  (interactive)
  (let ((filter (mu4e-read-option "Filter by: " mu4e-filters-enabled)))
    (funcall filter current-prefix-arg)))

(defun mu4e-filter-narrow-or-search (prefix query)
  "Filter messages by QUERY. If PREFIX is non-nil, search all
messages, else narrow current message list. See `mu4e-filter'."
  (if (equal prefix nil)
      (mu4e-headers-search-narrow query)
    (mu4e-headers-search query)))

;;; Customizable  variables

(defcustom mu4e-filters-enabled
  '(("attachment"   . mu4e-filter-by-attachment)
    ("date"         . mu4e-filter-by-date)
    ("gflagged"     . mu4e-filter-by-flag-status)
    ("hforwarded"   . mu4e-filter-by-forwarded)
    ("isize"        . mu4e-filter-by-size)
    ("list"         . mu4e-filter-by-mailing-list)
    ("priority"     . mu4e-filter-by-priority)
    ("trecipient"   . mu4e-filter-by-recipient)
    ("wreplied"     . mu4e-filter-by-replied-status)
    ("read"         . mu4e-filter-by-read-status)
    ("sender"       . mu4e-filter-by-sender)
    ("xGPG"         . mu4e-filter-by-gpg))
  "List of enabled filters.

An alist used by the function `mu4e-filters'. The CAR should be
the name of a filter as presented to the user, starting with a
unique character for the input key choice. The CDR should be the
name of a filter function.

By Using Emacs' Customize interface you can easily remove
unwanted filters, edit their input key, or add your own. Doing so
this way will replace this variable, meaning that filters added
to future versions of mu4e-filters will not be automatically
added to your filter list.

To modify this variable in such a way as to allow future versions
of this package to add new filters automatically, modify each
alist one-by-one. For example, to remove specific filters:

  (dolist (filter '(mu4e-filter-by-priority
  		    mu4e-filter-by-encrypted
		    mu4e-filter-by-unencrypted
		    mu4e-filter-by-signed
		    mu4e-filter-by-unsigned))
    (rassq-delete-all filter mu4e-filters-enabled))"
  :type '(alist :key-type string :key-value function)
  :group 'mu4e-filters)

(defcustom mu4e-filter-attachment-types
  '(("all files" . "flag:attach")
    ("music/audio" . "mime:audio/*")
    ("images" . "mime:image/*")
    ("pdf/presentations" . "mime:application/pdf or mime:application/vnd.oasis.opendocument.presentation or mime:application/vnd.ms-powerpoint or mime:application/vnd.openxmlformats-officedocument.presentationml.presentation or mime:application/vnd.apple.keynote or mime:application/vnd.kde.kpresenter")
    ("spreadsheets" . "mime:application/vnd.ms-excel or mime:application/vnd.oasis.opendocument.spreadsheet or mime:application/vnd.apple.numbers or mime:application/vnd.kde.kspread")
    ("videos" . "mime:video/*")
    ("writing" . "mime:application/vnd.openxmlformats-officedocument.wordprocessingml.document or mime:application/rtf or mime:application/vnd.oasis.opendocument.text or mime:application/vnd-wordperfect or mime:application/vnd.ms-word or mime:application/vnd.apple.pages or mime:application/vnd.kde.kword")
    ("zarchives" . "mime:application/x-bzip or mime:application/x-bzip2 or mime:application/gzip or mime:application/vnd.rar or mime:application/x-tar or mime:application/x-7z-compressed or mime:application/zip"))
   "Choice of attachment type filters.

An alist which populates the function
`mu4e-filter-by-attachment''s list of attachment filters. The CAR
of a each cons cell should be a title for the selection menu,
starting with a unique character for the input key choice. The
CDR should be a string containing MIME types prefixed by `mime:'
and separated by an `or'.

For example:
(add-to-list 'mu4e-filter-attachment-types '(\"cCalendar\" . \"mime:text/calender\"))"
  :type '(alist :key-type string :key-value string)
  :group 'mu4e-filters)

(defcustom mu4e-filter-list-of-dates
  '(("dates range" .
     (let* ((from-time (org-read-date nil t nil "From..."))
	    (from-date (format-time-string "%Y-%m-%d" from-time))
	    (to-date (org-read-date nil nil nil "To..." from-time)))
		  (concat from-date ".." to-date)))
    ("today" . "today..")
    ("wthis week" .
     (let* ((date-today (calendar-current-date))
	      (day-of-week (calendar-day-of-week date-today))
	      ;; How will this work on Sun when calendar-week-start-day is set to Monday
	      (days-into-week (- day-of-week calendar-week-start-day))
	      (abs-date-today (calendar-absolute-from-gregorian date-today))
	      (abs-date-start-of-week (- abs-date-today days-into-week))
	      (start-of-week (calendar-gregorian-from-absolute abs-date-start-of-week)))
	 (format "%d-%02d-%02d.." (nth 2 start-of-week) (nth 0 start-of-week) (nth 1 start-of-week))))
    ("Wpast week" . "7d..")
    ("fpast fortnight" . "2w..")
    ("mthis month" . (let* ((today (calendar-current-date))
			    (year (caddr today))
			    (month (car today)))
		       (format "%s-%s-01.." year month)))
    ("Mpast month" . "1m..")
    ("ythis year" . (let* ((today (calendar-current-date))
			   (year (caddr today)))
		      (format "%s-01-01.." year)))
    ("Ypast year" . "1y..")
    ("Ysince start of the year" . (format-time-string "%Y")))
   "Choice of date filters.

An alist which populates the function `mu4e-filter-by-date''s of
date filters. The CAR of each cons cell should be a title for the
selection menu, starting with a unique character for the input
key choice. The CDR should either be a string or a sexp which
returns a date filter. (See `man mu-query')."
   :type '(alist :key-type string :key-value sexp)
   :group 'mu4e-filters)

(defcustom mu4e-filter-implicit-email-lists nil
  "List of `List-Id'-lacking addresses to be considered email lists.

Some naughty email lists don't set a List-Id header, so
`mu4e-filter-by-mailing-list' won't be able to filter them by
default. As a workaround, it will also consider an email list any
messages whose :to field matches an address in this list.

Example usage:

  (setq mu4e-filter-implicit-email-lists '(\"PHILOS-L@liverpool.ac.uk\")"
  :type '(repeat string)
  :group 'mu4e-filters)

(defcustom mu4e-filter-sizes
  '(("01mb+" . "1m..")
    ("15mb+" . "5m..")
    ("210mb+" . "10m..")
    ("320mb+" . "20m..")
    ("430mb+" . "30m..")
    ("550mb+" . "50m.."))
   "Choice of message size filters.

Alist of sizes for `mu4e-filter-by-size' to offer to filter
 message by. The CAR should be the size as presented to the user,
 starting with a unique character for the input key choice. THE
 CDR should be a mu query size, without the `size:' prefix. (See
 `man mu-query'.)"
  :type '(alist :key-type string :key-value string)
  :group 'mu4e-filters)

;;; Filters

(defun mu4e-filter-by-attachment (prefix)
  "Filter by attachments, or specific attachment types.

Note that since this filters by MIME types, attachments with
misattributed MIME types, for example a PDF with a MIME type of
`application/data' or `application/octet-stream' instead of
`mime:application/pdf', will be missed by the filter. If this is
a problem try narrowing or searching by embeded text parts
instead. Eg, `/ embed:pdf <RET>'. Be aware this will also return
emails featuring the string `pdf' anywhere in the message

The choice of attachment types is determined by the variable
`mu4e-filter-attachment-types'."
  (interactive)
  (let ((query
	 (mu4e-read-option "Filter by MIME type of: " mu4e-filter-attachment-types)))
    (mu4e-filter-narrow-or-search prefix query)))

(defun mu4e-filter-by-date (prefix)
  "Filter by date.

The choice of dates is determined by the variable
`mu4e-filter-list-of-dates'."
  (interactive)
  (let ((choice (mu4e-read-option "Filter by: " mu4e-filter-list-of-dates)))
    (mu4e-filter-narrow-or-search prefix (format "date:%s" (if (listp choice)
							(eval choice)
						      choice)))))

(defun mu4e-filter-by-flag-status (prefix)
  "Filter flagged or unflagged messages"
  (interactive)
  (let ((choice (mu4e-read-option "Filter by: " '(("gflagged"   . mu4e-filter-by-flagged)
						  ("Gunflagged" . mu4e-filter-by-unflagged)))))
    (funcall choice prefix)))

(defun mu4e-filter-by-flagged (prefix)
  "Filter by flagged (starred) messages."
  (interactive)
  (mu4e-filter-narrow-or-search prefix "flag:flagged"))

(defun mu4e-filter-by-unflagged (prefix)
  "Filter by messages that have not been flagged."
  (interactive)
  (mu4e-filter-narrow-or-search prefix "not flag:flagged"))

(defun mu4e-filter-by-forwarded (prefix)
  "Filter by forwarded (`Passed' or `handled') messages."
  (interactive)
  (mu4e-filter-narrow-or-search prefix "flag:passed"))

(defun mu4e-filter-by-mailing-list (prefix)
  "Filter by mailing list at point.

This uses the List-ID header to detect the presence of a mailing
list at point. If a mailing list does not set such a header, this
function can be made to recognise it implicitly by adding its
address to the `mu4e-filter-implicit-email-lists' variable."
  (interactive)
  (let ((mailing-list (mu4e-message-field-at-point :mailing-list))
	(recipient (cdr (car (mu4e-message-field-at-point :to)))))
    (cond
     ((bound-and-true-p mailing-list) (mu4e-filter-narrow-or-search prefix (concat "list:" mailing-list)))
     ((member recipient mu4e-filter-implicit-email-lists)
      (mu4e-filter-narrow-or-search prefix (concat "to:" recipient)))
     (t (message "No mailing list here. Mistake? See variable `mu4e-filter-implicit-email-lists'.")))))

(defun mu4e-filter-by-priority (prefix)
  "Filter by priority."
  (interactive)
  (let ((priority (mu4e-read-option "Select message priority: "
				 '(("low" . low) ("medium" . medium) ("high" . high)))))
    (mu4e-filter-narrow-or-search prefix (format "prio:%s" priority))))

(defun mu4e-filter-by-recipient (prefix)
  "Filter by sender at point."
  (interactive)
  (let ((recipient (mu4e-message-field-at-point :to))
	(choice (mu4e-read-option "Filter by recipient's: "
				  '(("taddress"             . mu4e-filter-by-recipient-address)
				    ("faddress (from only)" . mu4e-filter-from-recipient-address)))))
    (funcall choice prefix recipient)))

(defun mu4e-filter-by-recipient-address (prefix recipient)
  "Filter by address of recipient at point."
  (interactive)
  (let ((recipient-email (cdr (car recipient))))
    (mu4e-filter-narrow-or-search prefix recipient-email)))

(defun mu4e-filter-from-recipient-address (prefix recipient)
  "Filter by address of recipient at point."
  (interactive)
  (let ((recipient-email (cdr (car recipient))))
    (mu4e-filter-narrow-or-search prefix (concat "from:" recipient-email))))

(defun mu4e-filter-by-replied-status (prefix)
  "Filter replied or unreplied messages"
  (interactive)
  (let ((choice (mu4e-read-option "Filter by: " '(("wreplied"   . mu4e-filter-by-replied)
						  ("Wunreplied" . mu4e-filter-by-unreplied)))))
    (funcall choice prefix)))

(defun mu4e-filter-by-replied (prefix)
  "Filter by messages that have been replied to."
  (interactive)
  (mu4e-filter-narrow-or-search prefix "flag:replied"))

(defun mu4e-filter-by-unreplied (prefix)
  "Filter by messages that have not been replied to."
  (interactive)
  (mu4e-filter-narrow-or-search prefix "not flag:replied"))

(defun mu4e-filter-by-read-status (prefix)
  "Filter read or unread messages"
  (interactive)
  (let ((choice (mu4e-read-option "Filter by: " '(("read"   . mu4e-filter-by-read)
						  ("Runread" . mu4e-filter-by-unread)))))
    (funcall choice prefix)))

(defun mu4e-filter-by-read (prefix)
  "Filter by read messages."
  (interactive)
  (mu4e-filter-narrow-or-search prefix "flag:seen"))

(defun mu4e-filter-by-unread (prefix)
  "Filter by unread messages."
  (interactive)
  (mu4e-filter-narrow-or-search prefix "flag:unread"))

(defun mu4e-filter-by-sender (prefix)
  "Filter by sender at point."
  (interactive)
  (let ((sender (mu4e-message-field-at-point :from))
	(choice (mu4e-read-option "Filter by sender's: "
				  '(("saddress"             . mu4e-filter-by-sender-address)
				    ("faddress (from only)" . mu4e-filter-from-sender-address)))))
    (funcall choice prefix sender)))

(defun mu4e-filter-by-sender-address (prefix sender)
  "Filter by messages which include sender at point in the To, From, CC and BCC."
  (interactive)
  (let ((sender-email (cdr (car sender))))
    (mu4e-filter-narrow-or-search prefix sender-email)))

(defun mu4e-filter-from-sender-address (prefix sender)
  "Filter by messages from sender at point."
  (interactive)
  (let  ((sender-email (cdr (car sender))))
    (mu4e-filter-narrow-or-search prefix (concat "from:" sender-email))))

(defun mu4e-filter-by-sender-name (prefix sender)
  "Filter by messages which include sender name at point in the To, From, CC and BCC."
  (interactive)
  (let ((sender-name (caar sender)))
    (mu4e-filter-narrow-or-search prefix sender-name)))

;; Unfinished
;; (defun mu4e-filter-by-sender-tld (prefix)
;;   "todo: should ignore subdomains.

;; Narrows the mu4e header view by the sender's domain at
;; point. If called with a prefix it performs a global search instead."
;;   (interactive)
  
;; (let* ((sender "daniel@mail.pompo.co")
;;        (sender-domain (cdr (split-string sender "@")))
;;        (sender-tld (split-string (car sender-domain)  "\\\.")))
;;   (if (length< sender-tld 3)
;;       (car sender-domain)
;;     (let ((tlds nil))
;;       (lambda (tlds)
;; 	(if (length= tlds 2)
;; 	    tlds
;; 	  ())))))

;;     (let* ((sender (cdr (car (mu4e-message-field-at-point :from))))
;; 	 (sender-domain  (cdr (split-string sender "@")))
;; 	 (sender-tlds (split-string sender-domain  "\\\.")))
;;     (message sender-domain)))

(defun mu4e-filter-by-size (prefix)
  "Filter by message size."
  (interactive)
  (let ((size (mu4e-read-option "Filter messages bigger than: "
				mu4e-filter-sizes)))
    (mu4e-filter-narrow-or-search prefix (format "size:%s" size))))

(defun mu4e-filter-by-gpg (prefix)
  "Filter by GPG related attributes, signed or encrypted"
  (interactive)
  (let ((choice (mu4e-read-option "Filter by: "
				  '(("xencrypted"   . mu4e-filter-by-encrypted)
				    ("Xunencrypted" . mu4e-filter-by-unencrypted)
				    ("signed"      . mu4e-filter-by-signed)
				    ("Sunsigned"    . mu4e-filter-by-unsigned)))))
    (funcall choice prefix)))

(defun mu4e-filter-by-encrypted (prefix)
  "Filter by encrypted messages."
  (interactive)
  (mu4e-filter-narrow-or-search prefix "flag:encrypted"))

(defun mu4e-filter-by-unencrypted (prefix)
  "Filter by encrypted messages."
  (interactive)
  (mu4e-filter-narrow-or-search prefix "not flag:encrypted"))

(defun mu4e-filter-by-signed (prefix)
  "Filter by signed messages."
  (interactive)
  (mu4e-filter-narrow-or-search prefix "flag:signed"))

(defun mu4e-filter-by-unsigned (prefix)
  "Filter by messages which are not signed."
  (interactive)
  (mu4e-filter-narrow-or-search prefix "not flag:signed"))


(provide 'mu4e-filter)
