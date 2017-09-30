#lang racket

;; ##################################################################################
;; # ============================================================================== #
;; # plugin.rkt                                                                     #
;; # https://github.com/Metaxal/MrEd-Designer                                       #
;; # Copyright (C) Laurent Orseau, 2010                                             #
;; # ============================================================================== #
;; #                                                                                #
;; # This program is free software; you can redistribute it and/or                  #
;; # modify it under the terms of the GNU General Public License                    #
;; # as published by the Free Software Foundation; either version 2                 #
;; # of the License, or (at your option) any later version.                         #
;; #                                                                                #
;; # This program is distributed in the hope that it will be useful,                #
;; # but WITHOUT ANY WARRANTY; without even the implied warranty of                 #
;; # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  #
;; # GNU General Public License for more details.                                   #
;; #                                                                                #
;; # You should have received a copy of the GNU General Public License              #
;; # along with this program; if not, write to the Free Software                    #
;; # Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.    #
;; #                                                                                #
;; ##################################################################################


;;; Generic Plugin Manager

(provide load-plugins)

(define (assoc-rest l key)
  (let ([val (assoc key l)])
    (if (and val (list? val))
        (rest val)
        '())))

;; If this file is present at the root of the plugin directory,
;; then plugins are loaded in the order given in the first list of the file
(define load-preferences-file "loading-preferences.rktd")

(define (load-preferences plugin-dir)
  (let ([pref-file (build-path plugin-dir load-preferences-file)])
    (if (file-exists? pref-file)
        (let ([pref-list (with-input-from-file pref-file
                          (λ()(read)))])
          (if (list? pref-list)
              pref-list
              (begin (printf "Error: The plugin preferences are not a list.\n")
                     '())))
        '())))

(define (load-plugin-from-path plugin-dir proc pdir)
  (let ([ppath (build-path plugin-dir pdir)])
    (if (directory-exists? ppath)
        (parameterize ([current-directory ppath])
          (list (proc pdir)))
        '())))

;; Plugin Loader
;; For each directory in the plugins-dir directory,
;; set the current-directory to that path,
;; and execute there hte procedure proc,
;; that receives the name of the directory.
;; Returns the list of applications of proc.
(define (load-plugins plugin-dir proc)
  (let* ([plugin-paths (directory-list plugin-dir)]
         [prefs (load-preferences plugin-dir)]
         [plugin-sequence (assoc-rest prefs 'sequence)]
         [dont-loads (assoc-rest prefs 'dont-load)]
         [load-plugin (λ (pdir) 
                        (if (member pdir dont-loads)
                            '()
                            (load-plugin-from-path plugin-dir proc pdir)))]
         )
    (append
      ; first load plugin if a sequence is provided from the sequence file
      (append-map
        load-plugin
        plugin-sequence)
     
      (append-map
        load-plugin
        ; remove plugins loaded in the first sequence
       (filter (λ (p) (not (member p plugin-sequence)))
               (map path->string plugin-paths)))
    )))
