#lang setup/infotab

(define name "MrEd Designer")
(define blurb
  `((p
     "Create Racket GUIs, WYSIWYG."
     (ul
     ; nope, now it's on github...
      (li (a ((href "http://mred-designer.origo.ethz.ch"))
             "Homepage"))
      (li (a ((href "http://mred-designer.origo.ethz.ch/wiki/doc"))
             "User's documentation"))
      (li (a ((href "http://mred-designer.origo.ethz.ch/wiki/developer_doc"))
             "Developer's documentation"))
      )
     )))
(define primary-file "main.rkt")
(define categories '(devtools misc ui))
(define homepage "http://mred-designer.origo.ethz.ch")
(define required-core-version "4.2.4")
;(define version "3.3")
(define repositories '("4.x"))
(define release-notes 
  '((ul
     (li "Racketify")
     (li "Fix save/load bug")
     )))
