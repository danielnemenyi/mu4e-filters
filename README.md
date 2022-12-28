
# Mu4e Filters

Mu4e Filters provides an easy and customizable search filter interface
for the Emacs email client [Mu4e](https://github.com/djcb/mu).
Install, press `,` (`M-x mu4e-filters`) on your message view and
consider that hosepipe filtered.

Mu4e Filters hopes to reduce the overhead of context switching that
the many kinds of messages is a typical inbox impose on a user. A
typical workflow using Mu4e Filter might involve, for example, dealing
with emails from the mailing list at point (`, l`), returning to the
inbox (`\`) dealing with those by the sender at point (`, s`), and so
on.

It also allows users to intuitively and easily perform complex and
non-trivial narrowing and search queries.

For example: *Filter the current email list by those from the sender
at point with a 'Word'-like attachment sent this month that I still
haven't replied to* (`, l , s f , a w , d m , W`).

Pressing `,` will make Mu4e Filters narrow the current header view by
that filter. To perform a global search of all your messages instead,
call it with a prefix argument instead (`C-u ,`).

It has helped me manage my daily email torrent, and I hope it helps
others too!

## Filters

| KEY | FILTER     | INFO                                                                                                       |
| --- |:----------:| ----------------------------------------------------------------------------------------------------------:|
| a   | Attachment | Filter by attachments or specific attachment MIME. Customize via the variable `mu4e-filter-by-attachment`. |
| d   | Date       | Filter by date range or relative date period.                                                              |
| g   | Flagged    | Filter by flagged ('starred') or unflagged messages.                                                       |
| h   | Forwarded  | Filter by forwarded ('Passed' or 'handled') messages.                                                      |
| i   | Size       | Filter by messages bigger than n                                                                           |
| l   | List       | Filter by email list at point                                                                              |
| p   | Priority   | Filter by message priority (as set by sender)                                                              |
| t   | Recipient  | Filter by the address in the :to field at point                                                            |
| w   | Replied    | Filter by replied or unreplied messages                                                                    |
| r   | Read       | Filter by read or unread messages                                                                          |
| s   | Sender     | Filter by sender at point                                                                                  |
| x   | GPG        | Filter by encrypted or signed messages                                                                     |

## Installation

Until this package is up on MELPA and other package managers, clone
this repo onto your computer and import it in your init.el with
`load-file`. For example:

``` emacs-lisp
(load-file (concat user-emacs-directory "lisp/mu4e-filters/mu4e-filters.el"))
```

## Customization

You can customize the behaviour of mu4e-filters via the mu4e-filters
menu in the Customize menu (`M-x customize-group RET mu4e-filters
RET`). Th

Else see the documentation for the variables `mu4e-filters-enabled`,
`mu4e-filter-attachment-types`, `mu4e-filter-list-of-dates`,
`mu4e-filter-implicit-email-lists`, `mu4e-filter-sizes`.

Mu4e-filters strives to be comprehensive and may provide more filters
than you care for. See the documentation for `mu4e-filters-enabled`
for how to remove them. A common customization may be:

``` emacs-lisp
(dolist (filter '(mu4e-filter-by-priority
		          mu4e-filter-by-encrypted
             	  mu4e-filter-by-unencrypted
		          mu4e-filter-by-signed
		          mu4e-filter-by-unsigned))
  (rassq-delete-all filter mu4e-filters-enabled))
```

## Support

Please get in touch via Github issues.
