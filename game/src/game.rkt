;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname game) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;Libraries for interactive programs and drawing

(require racket/base)
(require racket/class)
(require 2htdp/universe)
(require 2htdp/image)
(require net/sendurl)
 (require racket/string)
 
;Classes
(require "classes/Player.rkt")
(require "classes/Asteroid.rkt")
(require "classes/Bullet.rkt")
(require "classes/Sprite.rkt")
(require "classes/Upgrade.rkt")

; Media file, contains all declarations for images and sfx
(require "resources/media.rkt")

; a GUI is a structure (make-GUI lifes score)
;     where  lifes , score : Image
;   interpretation: stores the GUI elements to be overlayed on top of the game canvas
(define-struct GUI
  [lifes score] #:mutable)

;Step 1: Data types
; an AppState is a structure (make-AppState background GUIoverlay player list-upgrades list-bullets list-asteroids))
;    where background  : Image
;          GUIoverlay  : GUI
;          player      : object of class %player
;          list-upgrades : List<%upgrade>
;          list-bullets : List<%bullet>
;          list-asteroids : List<%asteroid> 
; interpretation: a struct containing all the relevant informations for the game to function properly
(define-struct AppState
  [background 
   GUIoverlay
   player
   list-upgrades
   list-bullets
   list-asteroids
   ] #:mutable)

;;;Data examples
(define State1 (make-AppState
       ; The CANVAS is treated as a %sprite, positioned at the center of itself.
       (new sprite% (an-Image BLANK-CANVAS) (a-Posn (make-posn (/ (image-width BLANK-CANVAS) 2) (/ (image-height BLANK-CANVAS) 2)))(a-SpeedStruct (make-posn 0 0)))
       ; Blank GUI.   GUI gets computed after the AppState has been created
       (make-GUI (square 0 "solid" "red")(square 0 "solid" "red"))
       (new player% (an-Image SPACESHIP1-IMG)(playerName "TheLegend64") (a-Posn (make-posn (/ (image-width BLANK-CANVAS) 2) (image-height BLANK-CANVAS) )) (startingLifes 20))
       
       ;List of upgrades on screen
       (list (new upgrade% 
                (a-Posn (make-posn 300 900)) 
                (a-SpeedStruct (make-posn 0 0))
                (a-Name "speedMul"))
              (new upgrade% 
                (a-Posn (make-posn 600 700)) 
                (a-SpeedStruct (make-posn 0 0))
                (a-Name "front"))
              (new upgrade% 
                (a-Posn (make-posn 900 700)) 
                (a-SpeedStruct (make-posn 0 0))
                (a-Name "diagonal"))
              (new upgrade% 
                (a-Posn (make-posn 1200 100)) 
                (a-SpeedStruct (make-posn 0 0))
                (a-Name "life")))
       
       ;List of bullets on screen
       (list )
       ;List of asteroids on screen
       (list )))


;Step 2 . Input/Output

; Signature: draw : AppState -> Image
; Purpose Statement: Takes the AppState and draws the game screen by drawing all the %sprites (player, asteroids, bullets, upgrades, CANVAS) and overlays the GUI elements (life,score) on top of it
; Header/Stub: (define (draw appstate) (square 20 "solid" "black"))

;Step 4 . Template

;(define (draw appstate)
;  (local
;    ((define GUI (AppState-GUIoverlay appstate))
;      (define DRAW-QUEUE (append ... ... ))
;    (define (draw.v2 draw-obj)
;      (cond
;           [(empty? draw-obj) ...]
;           [(cons? draw-obj )
;            (local
;              ((define element (...))
;              ( define element-image (...))
;              ( define element-position (...) ))
;              
;              (place-image/align ... element-image ... element-position ... (draw.v2 ...) ...  ))])))
;    (place-images/align
;        (list ... GUI ... )
;        (list ... (make-posn ... ) ...)
;        (draw.v2 ... ))))


; Step 5 . Code

(define (draw appstate)
  (local
    ((define GUI (AppState-GUIoverlay appstate))
      (define DRAW-QUEUE (append 
                                (AppState-list-asteroids appstate)
                                (AppState-list-upgrades appstate)
                                (list (AppState-player appstate))
                                (AppState-list-bullets appstate)  ))
    (define (draw.v2 draw-obj)
      (cond
           [(empty? draw-obj) (get-field image (AppState-background appstate))]
           [(cons? draw-obj)
            (local
              ((define element (first draw-obj))
              ( define element-image (get-field image element))
              ( define element-position (get-field position element)))
              
              (place-image/align element-image
                                 (posn-x element-position)  (posn-y element-position) "center" "center"
                                 (draw.v2 (rest draw-obj)) ))])))
    (place-images/align
        (list
              (GUI-lifes GUI)    (GUI-score GUI))
        (list (make-posn 0 0)    (make-posn 0 (- (image-height BLANK-CANVAS) (image-height (GUI-score GUI)))))
        "left" "top"
        (draw.v2 DRAW-QUEUE))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;Step 2 . Input/Output

; Signature:         computeLifesGUI : AppState -> (void)
; Purpose Statement: Refreshes the GUI-lifes Image based on the player's health. Renders 10 hearts per line, then goes to newline
; Header/Stub:       (define (computeLifesGUI appstate) (void))

;Step 4. Template

;(define (computeLifesGUI appstate)
;  (local
;    ((define (renderLife n)
;        (cond
;          [(= n 0) ...n...]
;          [(or (= (modulo n ...) ...)(> n ...)) (above/align ... (renderHearts ...) (renderLife ...))) ]
;          [else (renderHearts n)]))
;      
;      (define (renderHearts n)
;        (cond
;          [(= n ...) ...]
;          [(> n ...) (beside/align ... ... (renderHearts ...))]) ))
;
;    (set-GUI-lifes!      
;      (AppState-GUIoverlay appstate)
;      (renderLife ...))))

;Step 5. Code

(define (computeLifesGUI appstate)
  (local
    ((define (renderLife n)
        (cond
          [(= n 0) (square 0 "solid" "transparent")]
          [(or (= (modulo n 10) 0)(> n 10)) (above/align "left" (renderHearts 10) (renderLife (- n 10))) ]
          [else (renderHearts n)]))
      
      ; Renders hearts in a straight line
      (define (renderHearts n)
        (cond
          [(= n 1) HEART-IMG]
          [(> n 1) (beside/align "top" HEART-IMG (renderHearts (- n 1)))]) ))

    ; Sets the GUI-lifes with the new computed Image
    (set-GUI-lifes!      
      (AppState-GUIoverlay appstate)
      (renderLife (get-field lifes (AppState-player appstate))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Step 2 . Input/Output

; Signature: computeWholeGUI : AppState-> (void)
; Purpose Statement: Individually calls computeLifesGUI and computeScoreGUI to compute the all the GUI elements
; Header/Stub: (define (computeWholeGUI apppstate)(void))

; Step 4. Template:

; (define (computeWholeGUI appstate)
;   (computeLifesGUI ...)
;   (computeScoreGUI ...))

; Step 5. Code

(define (computeWholeGUI appstate)
  (computeLifesGUI appstate)
  (computeScoreGUI appstate))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 .Input/Output

; Signature: computeScoreGUI : AppState -> (void)
; Purpose Statement: Sets the GUI score of the player
; Header/Stub (define (computeScoreGUI appstate)(void))

;Step 4. Template

;(define (computeScoreGUI appstate)
;  (set-GUI-score!      
;      (AppState-GUIoverlay ...)
;      (text/font (string-append ... )...) #f)))


;Step 5. Code

(define (computeScoreGUI appstate)
  (set-GUI-score!      
      (AppState-GUIoverlay appstate)
      (text/font (string-append "SCORE: " (number->string (get-field score (AppState-player appstate)))) (ceiling (* 80 screenScale)) "yellow"
             "Gill Sans" 'swiss 'normal 'bold #f)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: shoot : AppState -> (void)
; Purpose Statement: Creates the newly-shot bullets of the player and appends them to AppState-list-bullets
; Header/Stub (define (shoot appstate)(void))

;Step 4 . Template

;(define (shoot appstate)
;  (set-AppState-list-bullets! ...)
;   (append (AppState-list-bullets ...) (send (AppState-player ...) ...)))...)

;Step 5 . Code

(define (shoot appstate)
  (set-AppState-list-bullets!
   appstate
   (append (AppState-list-bullets appstate) (send (AppState-player appstate) shoot)))
   appstate)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: movePlayer : AppState Integer Integer -> AppState
; Purpose Statement: Moves the player to new coordinates
; Header/Stub (define (movePlayer appstate x y ) ASS1)

;Step 3. Examples
(check-expect (movePlayer State1 20 20 ) State1)
(check-expect (movePlayer ASS1 123 40 ) ASS1)


;Step 4 . Template
;(define (movePlayer appstate x y)
;  (set-field! position ... ...)... )

;Step 5. Code

(define (movePlayer appstate x y)
  (set-field! position (AppState-player appstate)  (make-posn x y))
  appstate)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2. Input/Output
; Signature: handle-mouse : AppState Integer Integer String -> AppState
;   - "button-down" : shoot bullet/s
;   - "drag" : moves the player
;   - "move" : moves the player

; Header/Stub (define (handle-mouse appstate x y e ) ASS1)

;Step 3 .Examples
(check-expect (handle-mouse ASS1   30   49  "drag" ) ASS1)
(check-expect (handle-mouse State1   20   0  "move" ) State1)

;Step 4. Template

;(define (handle-mouse appstate x y e)
;  (cond
;    [(= e "button-down") (... appstate ... x ... y ...)]
;    [(= e "drag")        (... appstate ... x ... y ...)]
;    [(= e "move")        (... appstate ... x ... y ...)]
;    [else                (... appstate ...)])
   
; Step 5 . Code

(define (handle-mouse appstate x y e)
  (cond
    [(string=? e "button-down") (shoot appstate)]
    [(string=? e "drag") (movePlayer appstate x y)]
    [(string=? e "move") (movePlayer appstate x y)]
    [else appstate]) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: increment-posn : Posn Posn -> Posn
; Purpose Statement:  Adds two Posn's X and Y components together respectively
; Header/Stub (define (increment-posn posn1 posn2) (make-posn 2 3))

; Step 3 . Examples
(check-expect (increment-posn (make-posn 4 6 ) (make-posn 3 7 ))(make-posn 7 13))
(check-expect (increment-posn (make-posn 20 -30 ) (make-posn 50 12 ))(make-posn 70 -18))
(check-expect (increment-posn (make-posn 40 20 ) (make-posn 80 12 ))(make-posn 120 32))


;Step 4 . Template

;(define (increment-posn posn1 posn2)
;  (make-posn (...posn-x...)(...posn-y...)))

;Step 5 . Code

(define (increment-posn posn1 posn2)
  (make-posn (+(posn-x posn1) (posn-x posn2)) (+(posn-y posn1) (posn-y posn2))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: apply-speed : List  -> (void)
; Purpose Statement:  Applies the speed to a list of %sprite objects
; Header/Stub (define (apply-speed obj-list)obj-list)

;Step 4 . Template

;(define (apply-speed sprite-list)
;    (for-each (lambda (x)...)...))

;Step 5 . Code

(define (apply-speed sprite-list)
    (for-each (lambda (sprite)
           (send sprite apply-speed))
         sprite-list))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output


; Signature: colliding? : %sprite %sprite -> Boolean
; Purpose Statement: Checks if two %sprite objects are colliding or not
; Header/Stub (define (colliding?  sprite1 sprite2) #true)

;Step 4 . Template

;(define (colliding? sprite1 sprite2)
;  (local
;    ((define pos2 ...)
;     (define difference (increment-posn ...))))  
;    (and
;     (< (... (posn-x difference)) ...)))
;     (< (... (posn-y difference))... )))))

;Step 5 . Code

(define (colliding? sprite1 sprite2)
  (local
    ((define pos2 (get-field position sprite2))
     (define difference (increment-posn (get-field position sprite1) (make-posn (* (posn-x pos2) -1) (* (posn-y pos2) -1)))))  
    (and
     (< (abs (posn-x difference)) (+ (/(image-width (get-field image sprite1)) 2) (/(image-width (get-field image sprite2)) 2)))
     (< (abs (posn-y difference)) (+ (/(image-height (get-field image sprite1)) 2) (/(image-height (get-field image sprite2)) 2))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



; Step 2 . Input/Output

; Signature: remNotVisible : AppState -> (void)
; Purpose Statement: Removes %sprites that are no longer visible on the CANVAS. 
;                    Since CANVAS is also a %sprite, the other sprites are visible when they are colliding with the CANVAS %sprite
; Header/Stub (define (remNotVisible appstate) (void))

;Step 4 . Template

;(define (remNotVisible appstate)
;  (set-AppState-list-bullets! ...
;                                 (filter (lambda (x)
;                                           (colliding? ...))
;  (set-AppState-list-asteroids! ...
;                                 (filter (lambda (x)
;                                           (colliding? ...))
;  (set-AppState-list-upgrades! ...
;                                 (filter (lambda (x)
;                                           (colliding? ...)))

;Step 5 . Code

(define (remNotVisible appstate)
  (set-AppState-list-bullets! appstate
                                 (filter (lambda (x)
                                           (colliding? x (AppState-background appstate))) (AppState-list-bullets appstate)))
  (set-AppState-list-asteroids! appstate
                                 (filter (lambda (x)
                                           (colliding? x (AppState-background appstate))) (AppState-list-asteroids appstate)))
  (set-AppState-list-upgrades! appstate
                                 (filter (lambda (x)
                                           (colliding? x (AppState-background appstate))) (AppState-list-upgrades appstate))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;
;; BULLET-ASTEROID INTERACTIONS



; Step 2 . Input/Output

; Signature:           check-Bullet-Asteroid-collision : AppState -> (void)
; Purpose Statement:   Check for collisions between the %bullet's and the %asteroid's
; Header/Stub          (define (check-Bullet-Asteroid-collision appstate) (void))

;Step 4 . Template

;(define (check-Bullet-Asteroid-collision appstate)
;  (local
;    ((define PLAYER (AppState-player appstate)))
;    (void (map (lambda (bullet)          
;            (ormap (lambda (asteroid)
;                    (cond
;                      [(colliding? ... ...) (register-Bullet-Asteroid-hit ...) #true]
;                      [else #false])) ...))))

;Step 5. Code

(define (check-Bullet-Asteroid-collision appstate)
  (local
    ((define PLAYER (AppState-player appstate)))
    ; Cycles through every bullet
    (void (map (lambda (bullet) 
            ; Cycles through every asteroid until he finds a hit
            (ormap (lambda (asteroid)
                    (cond
                      ; If the bullet and the asteroid are colliding: Registers the hit and returns #true for the (ormap) to stop
                      [(colliding? bullet asteroid) (register-Bullet-Asteroid-hit appstate PLAYER bullet asteroid) #true]
                      [else #false])) (AppState-list-asteroids appstate))) (AppState-list-bullets appstate)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: register-Bullet-Asteroid-hit  : AppState %player %bullet %asteroid -> (void)
; Purpose Statement: Called when there is a collision between a bullet and an asteroid
; Header/Stub (define (register-Bullet-Asteroid-hit appstate player bullet asteroid) (void))

;Step 4 . Template

;(define (register-Bullet-Asteroid-hit appstate player bullet asteroid)
;  (set-AppState-list-bullets! ... (remove bullet (...))
;  (send asteroid hit)
;  (set-AppState-list-asteroids! ... (remove asteroid (...)))
;  (send player increase-score ...)
;  (computeScoreGUI ...))

;Step 5 . Code

(define (register-Bullet-Asteroid-hit appstate player bullet asteroid)
  ; Removes the %bullet object
  (set-AppState-list-bullets! appstate (remove bullet (AppState-list-bullets appstate)))

  ; Triggers the %asteroid object's hit function
  (send asteroid hit)
  ; Removes the %asteroid object
  (set-AppState-list-asteroids! appstate (remove asteroid (AppState-list-asteroids appstate)))
  
  (send player increase-score 100)
  ; Recomputes GUI-score
  (computeScoreGUI appstate))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; PLAYER-ASTEROID INTERACTION

; Step 2 . Input/Output

; Signature: check-Player-Asteroid-collision  : AppState  -> (void)
; Purpose Statement: Checks for a collision between the player and the asteroid
; Header/Stub (define (check-Player-Asteroid-collision appstate) (void))

;Step 4 . Template

;(define (check-Player-Asteroid-collision appstate)
;  (local
;    ((define PLAYER (AppState-player appstate)))
;    (void (ormap (lambda (asteroid)
;                    (cond
;                      [(colliding? ... ...) (register-Player-Asteroid-hit ...) #true]
;                      [else #false])) ...))

;Step 5 . Code

(define (check-Player-Asteroid-collision appstate)
  (local
    ((define PLAYER (AppState-player appstate)))
    ; Cycles through every asteroid
    (void (ormap (lambda (asteroid)
                    (cond
                      ; If the asteroid and the player are colliding: Registers the hit and returns #true for the (ormap) to stop
                      [(colliding? PLAYER asteroid) (register-Player-Asteroid-hit appstate PLAYER asteroid) #true]
                      [else #false])) (AppState-list-asteroids appstate)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: register-Player-Asteroid-hit    : AppState %player %asteroid -> (void)
; Purpose Statement: Called when there is a collision between the player and an asteroid
; Header/Stub (define (register-Player-Asteroid-hit appstate player asteroid) (void))

;Step 4 . Template

;(define (register-Player-Asteroid-hit appstate player asteroid)
;  (send player hit)
;  (set-AppState-list-asteroids! ... (remove ... (...)))
;  (computeLifesGUI ...))

;Step 5 . Code

(define (register-Player-Asteroid-hit appstate player asteroid)
  ; Calls the %player object's hit function
  (send player hit)
  ; Removes the asteroid
  (set-AppState-list-asteroids! appstate (remove asteroid (AppState-list-asteroids appstate)))
  ; Recomputes GUI-lifes
  (computeLifesGUI appstate))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; PLAYER-UPGRADE INTERACTION

; Step 2 . Input/Output

; Signature: check-Player-Upgrade-collision   : AppState -> (void)
; Purpose Statement: Checks for colllisions between the player and the upgrades
; Header/Stub (define (check-Player-Upgrade-collision appstate) (void))

;Step 4 . Template

;(define (check-Player-Upgrade-collision appstate)
;  (local
;    ((define PLAYER (...)))
;    (map (lambda (upgrade)
;            (if (colliding? ...)
;              (register-Player-Upgrade-collision ...)
;              (...))) 
;          (AppState-list-upgrades ...)) ))

;Step 5 . Code

(define (check-Player-Upgrade-collision appstate)
  (local
    ((define PLAYER (AppState-player appstate)))
    (void (ormap (lambda (upgrade)
                    (cond
                      ; If the player and the upgrade are colliding: Registers the collision and returns #true for the (ormap) to stop
                      [(colliding? PLAYER upgrade) (register-Player-Upgrade-collision appstate PLAYER upgrade) #true]
                      [else #false])) (AppState-list-upgrades appstate))) ))

;;;;;;,,,,,,,,,,,,,,,,,,,,,
; Step 2 . Input/Output

; Signature: register-Player-Upgrade-collision    : AppState %player %upgrade -> (void)
; Purpose Statement: Called when there is a collision between the player and an upgrade
; Header/Stub (define (register-Player-Upgrade-collision appstate player upgrade) (void))

;Step 4 . Template

;(define (register-Player-Upgrade-collision appstate player upgrade)
;  (send player add-upgrade ...)
;  (set-AppState-list-upgrades! ... (remove ... (...)))
;  (computeLifesGUI ...))

;Step 5 . Code
(define (register-Player-Upgrade-collision appstate player upgrade)
  ; Calls the %player object's add-upgrade function and gives in input the %upgrade
  (send player add-upgrade upgrade)
  ; Removes the upgrade
  (set-AppState-list-upgrades! appstate (remove upgrade (AppState-list-upgrades appstate)))
  
  (computeLifesGUI appstate))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Step 2 .Input/Output
; Signature: tick : AppState -> AppState
; Purpose Statement: spawns, animates %sprite 's elements and checks for collisions
; header: (define (tick appstate) appstate)

; Step 3 . Examples
(check-expect ( tick State1) State1 )
(check-expect ( tick ASS1) ASS1 )

;Step 4 . Template

;(define (tick appstate)
;  (spawnElements ...)
;  (apply-speed (append ... ... ...))
;  (remNotVisible ...)
;  (check-Player-Upgrade-collision ...)
;  (check-Player-Asteroid-collision ...)
;  (check-Bullet-Asteroid-collision ...)
;  ...)

(define (tick appstate)
  ; Spawns new %sprite objects (asteroids, upgrades)
  (spawnElements appstate)
  ; Applies the speed of every %sprite object to it.
  (apply-speed (append (AppState-list-upgrades appstate) (AppState-list-bullets appstate) (AppState-list-asteroids appstate)))
  ; Removes any %sprite object that is not visible on screen anymore
  (remNotVisible appstate)

  ;; Collisions check
  (check-Player-Upgrade-collision appstate)
  (check-Player-Asteroid-collision appstate)
  (check-Bullet-Asteroid-collision appstate)

  appstate)

;;;;;;;;;;;;;;;;;;;;;;;;
;; ELEMENT SPAWNING

; Step 2 . Input/Output

; Signature: spawnElements : AppState -> (void)
; Purpose Statement: Spawns new %asteroid and %upgrade objects
; Header/Stub (define (spawnElements appstate)(void))

;Step 4 . Template

;(define (spawnElements appstate)
;  (set-AppState-list-asteroids! ... (spawn-asteroid (...)))
;  (set-AppState-list-upgrades! ... (spawn-upgrade (...))))

;Step 5 . Code

(define (spawnElements appstate)
  (set-AppState-list-asteroids! appstate (spawn-asteroid (AppState-list-asteroids appstate)))
  (set-AppState-list-upgrades! appstate (spawn-upgrade (AppState-list-upgrades appstate)))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ASTEROID SPAWNING

; Step 2 . Input/Output

; Signature: spawn-asteroid  :  List<%asteroid>  -> List<%asteroid>
; Purpose Statement: Spawns a new %asteroid object based on probability
; Header/Stub (define (spawn-asteroid list-asteroids)list-asteroids)

;Step 4 . Template

;(define (spawn-asteroid list-asteroids)
;  (local
;    ((define asteroid-speed ...) (define density ...))
;      (cond
;        [(< (random ...) density) (cons (new asteroid% ...]
;        [else ...])))

;Step 5 . Code

(define (spawn-asteroid list-asteroids)
  (local
    ((define asteroid-speed 5) (define density 1000))
      (cond
        [(< (random 10000) density) (cons (new asteroid% (an-Image (scale (/(+(random 10)3) 6) ASTEROID1-IMG)) (a-Posn (make-posn (random (image-width BLANK-CANVAS)) 0)) (a-SpeedStruct (make-posn 0 (* (/ (+(random 100)1) 35) asteroid-speed)))) list-asteroids)]
        [else list-asteroids])))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UPGRADE SPAWNING

; Step 2 . Input/Output

; Signature: spawn-upgrade  : List<%upgrade>  -> List<%upgrade> 
; Purpose Statement: Spawns a new %upgrade object based on probability
; Header/Stub (define (spawn-upgrade list-upgrades) list-upgrades)

;Step 4 . Template

;(define (spawn-upgrade list-upgrades)
;  (local
;    ((define upgrade-speed ...) (define density ...))
;      (cond
;        [(< (random ...) density) (cons (new upgrade% 
;                                            (...a-Posn...)...)) 
;                                            (...a-SpeedStruct...))
;                                            (...a-Name... )) 
;                                          ...)]
;        [else ...])) )

;Step 5 . Code
(define (spawn-upgrade list-upgrades)
  (local
    ((define upgrade-speed 5) (define density 8))
      (cond
        [(< (random 10000) density) (cons (new upgrade% 
                                            (a-Posn (make-posn (random (image-width BLANK-CANVAS)) 0)) 
                                            (a-SpeedStruct (make-posn 0 (* (/ (+(random 100)1) 35) upgrade-speed)))
                                            (a-Name (random-upgrade))) 
                                          list-upgrades)]
        [else list-upgrades])) )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define (game-end? appstate)
  (local
    ((define quit (zero? (get-field lifes (AppState-player appstate)))))
    (cond
      [(equal? quit #true) (endgame appstate) quit]
      [(equal? quit #false) quit])))


(define (game appstate)
  (computeWholeGUI ASS1)
  (big-bang appstate
    [to-draw draw]
    [on-mouse handle-mouse]
    [on-tick tick ]
    [stop-when game-end?])
    (set! ASS1 (resetGame)))


(define (endgame appstate)
  (leaderboard appstate))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Step 2 . Input/Output

; Signature: leaderboard  : AppState  -> (void)
; Purpose Statement: Opens the leaderboard with the scores of players around the world.
;                       when appstate is set, it send the current game's data to the server that puts it into the leaderboard
; Header/Stub (define (leaderboard appstats) (void))

;Step 4 . Template

;(define (leaderboard appstate))
;  (cond
;    [(equal? appstate (void)) (send-url ...)]
;    [else (send-url ...)]) )

(define (leaderboard appstate)
  (cond
    [(equal? appstate (void)) (send-url "http://cerfeda.com/")]
    [else (send-url (string-append "http://cerfeda.com/?player=" 
                                  (get-field name (AppState-player appstate)) 
                                  "&score=" (number->string (get-field score (AppState-player appstate))) 
                                  "&lives=" (number->string (get-field starting-lifes (AppState-player appstate)))))]) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Step 2 . Input/Output

; Signature: leaderboard  :   -> AppState
; Purpose Statement: returns a new AppState
; Header/Stub: (define (resetGame) ASS1)

;Step 4 . Template
;(define (resetGame))
;  (make-AppState ... ) )

(define (resetGame)
  (make-AppState
        ; The CANVAS is treated as a %sprite, positioned at the center of itself.
        (new sprite% (an-Image BLANK-CANVAS) (a-Posn (make-posn (/ (image-width BLANK-CANVAS) 2) (/ (image-height BLANK-CANVAS) 2)))(a-SpeedStruct (make-posn 0 0)))
        ; Blank GUI.   GUI gets computed after the AppState has been created
        (make-GUI (square 0 "solid" "red")(square 0 "solid" "red"))
        (new player% (an-Image SPACESHIP1-IMG)(playerName "TheLegend64") (a-Posn (make-posn (/ (image-width BLANK-CANVAS) 2) (image-height BLANK-CANVAS) )) (startingLifes 20))
        
        ;List of upgrades on screen
        (list (new upgrade% 
                  (a-Posn (make-posn 300 900)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "speedMul"))
                (new upgrade% 
                  (a-Posn (make-posn 300 700)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "speedMul"))
                (new upgrade% 
                  (a-Posn (make-posn 600 100)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "front"))
                (new upgrade% 
                  (a-Posn (make-posn 600 300)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "front"))
                (new upgrade% 
                  (a-Posn (make-posn 600 500)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "front"))
                (new upgrade% 
                  (a-Posn (make-posn 600 700)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "front"))
                (new upgrade% 
                  (a-Posn (make-posn 900 100)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "diagonal"))
                (new upgrade% 
                  (a-Posn (make-posn 900 300)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "diagonal"))
                (new upgrade% 
                  (a-Posn (make-posn 900 500)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "diagonal"))
                (new upgrade% 
                  (a-Posn (make-posn 900 700)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "diagonal"))
                (new upgrade% 
                  (a-Posn (make-posn 1200 100)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "life"))
                (new upgrade% 
                  (a-Posn (make-posn 1200 300)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "life"))
                (new upgrade% 
                  (a-Posn (make-posn 1200 500)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "life"))
                (new upgrade% 
                  (a-Posn (make-posn 1200 700)) 
                  (a-SpeedStruct (make-posn 0 0))
                  (a-Name "life"))
                )
        
        ;List of bullets on screen
        (list )
        ;List of asteroids on screen
        (list )))

(define ASS1 (resetGame))

(provide AppState-player)
(provide game)
(provide ASS1)
(provide leaderboard)