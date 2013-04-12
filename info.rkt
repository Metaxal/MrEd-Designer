#lang setup/infotab

(define name "MrEd Designer")
(define blurb
  `((p
     "Create Racket GUIs, WYSIWYG."
     (ul
     ; nope, now it's on github...
      (li (a ((href "https://github.com/Metaxal/MrEd-Designer"))
             "Homepage and documentation (user and developper)"))
      )
     )))
(define primary-file "mred-designer/main.rkt")
(define categories '(devtools misc ui))
(define homepage "https://github.com/Metaxal/MrEd-Designer")
(define required-core-version "5.0")
;(define version "3.3")
(define repositories '("4.x"))
(define release-notes 
  '((ul
     (li "Racketify, Planet2ify")
     )))
