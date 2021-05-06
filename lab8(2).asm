TITLE ЛР_8
;------------------------------------------------------------------------------
;ЛР  №8
;------------------------------------------------------------------------------
; Архітектура комп'ютера.
; ВУЗ:          НТУУ "КПІ"
; Факультет:    ФІОТ
; Курс:         1
; Група:        ІТ-01
;------------------------------------------------------------------------------
; Автор:        Гончаренко, Доброхотова, Нікітченко
; Дата:         06/05/2021
;----------------------------I.ЗАГОЛОВОК ПРОГРАМИ------------------------------
IDEAL			             ; Директива - тип Асемблера tasm 
MODEL small		             ; Директива - тип моделі пам’яті 
STACK 2048		             ; Директива - розмір стеку 
;----------------------------II.ПОЧАТОК СЕГМЕНТУ ДАНИХ-------------------------
DATASEG
;------------------------------------------------------------------------------
MENU db  '                  '                    ; Меню програми
     db  '  View creators   '
     db  '  Beep            '
     db  '  Solve equation  '
     db  '                  ' 
;------------------------------------------------------------------------------
HELP_OUT db 'To select an item, use <Up/Down> arrow and press <Enter>. Press <Esc> to exit.'
OUTPUT_SIZE=$-HELP_OUT
CREATORS db ' IT-01 Team: 4 Honcharenko, Dodrohotova, Nikitchenko                          '
EQUATION db ' ((-1-1)*2*2+3)=                                                              '
EQUATION_SIZE EQU 16
;------------------------------------------------------------------------------
a1 db -1                     ; Значення, які підставлятимуться в формулу
a2 db 1
a3 db 2
a4 db 2
a5 dw 3
;------------------------------------------------------------------------------
FREQUENCY EQU 20
TIME EQU 3500
;------------------------------------------------------------------------------
MENU_COLOR EQU 0070h
CURRENT_COLOR EQU 0020h
OUTPUT_COLOR EQU 0020h
;------------------------------------------------------------------------------
SYMBOLS_COUNT EQU 18
TOP_ROW EQU  10
BOTTOM_ROW EQU 14
LEFT_COL EQU 27
OUTPUT_ROW EQU 18
MENU_ITEMS EQU 3
CURRENT_ROW db 1
;----------------------------ІІІ. ПОЧАТОК СЕГМЕНТУ КОДУ------------------------
CODESEG
;------------------------------------------------------------------------------
MACRO M_pushRegisters        ; Макрос для запам'ятовування значень регістрів
 push ax
 push bx
 push cx
 push dx
 push bp
 push si
 push di
ENDM M_pushRegisters
;------------------------------------------------------------------------------
MACRO M_popRegisters         ; Макрос для повернення значень регістрів
 pop di
 pop si
 pop bp
 pop dx
 pop cx
 pop bx
 pop ax
ENDM M_popRegisters
;------------------------------------------------------------------------------
MACRO M_drawOut              ; Макрос для виведення
 mov dh, OUTPUT_ROW          ; Початок виведення зверху  
 mov dl, 0                   ; Початок виведення зліва  
 mov ax, 1300h               ; Функція для відображення символів 
 mov bx, OUTPUT_COLOR        ; Колір виводу
 mov cx, OUTPUT_SIZE         ; Кількість символів для відображення
 int 10h                     ; Виклик переривання BIOS
ENDM M_drawOut
;------------------------------------------------------------------------------
PROC clearScreen             ; Процедура для очищення екрану
 M_pushRegisters

 mov ax, 0600h               ; Функція для залиття екрану
 mov bh, 30h                 ; Колір фону
 mov cx, 0                   ; Відступ зліва
 mov dx, 184Fh               ; dh, dl - кількість зафарбованих рядків, колонок
 int 10h                     ; Переривання BIOS

 M_popRegisters
 ret                         ; Повернення з процедури
ENDP clearScreen             ; Кінець процедури
;------------------------------------------------------------------------------
PROC drawMenu                ; Процедура для виведення меню
 M_pushRegisters

 mov dh, TOP_ROW             ; Початок виведення зверху  
 mov dl, LEFT_COL            ; Початок виведення зліва  
 mov ax, 1300h               ; Функція відображення символів 
 mov bx, MENU_COLOR          ; Колір меню
 mov cx, SYMBOLS_COUNT       ; Кількість символів для відображення
 xor si, si                  ; Вибраний рядок

main_loop_1:          
 lea bp, [MENU+si]           ; Вибір рядка для відображення
 int 10h                     ; Виклик переривання BIOS
 inc dh                      ; Збільшення dh
 add si, SYMBOLS_COUNT       ; Збільшення si
 cmp dh, BOTTOM_ROW+1        ; Перевірка на кінець меню
 jne main_loop_1             ; Перевірка на кінець меню

 M_popRegisters
 ret                         ; Повернення з процедури
ENDP drawMenu                ; Кінець процедури
;------------------------------------------------------------------------------
PROC drawCurrent
 M_pushRegisters

 call drawMenu
 mov dh, [CURRENT_ROW]       ; Початок виведення зверху
 add dh, TOP_ROW
 mov dl, LEFT_COL+1          ; Початок виведення зліва  
 mov cx, SYMBOLS_COUNT-2     ; Кількість символів для відображення
 mov al, SYMBOLS_COUNT
 mov bl, [CURRENT_ROW]       ; Визначаємо, який пункт буде обрано
 mul bl
 mov si, ax
 mov ax, 1300h               ; Функція відображення символів 
 mov bx, CURRENT_COLOR       ; Колір вибраного пункту
 lea bp, [MENU+si+1]         ; Вибір рядка для відображення
 int 10h                     ; Переривання BIOS

 M_popRegisters
 ret                         ; Повернення з процедури
ENDP drawCurrent             ; Кінець процедури
;------------------------------------------------------------------------------
PROC inputChecker
 M_pushRegisters
 
input_loop_1:
 mov ah, 10h                 ; Функція для зчитування з клавіатури
 int 16h
 cmp ah, 50h                 ; Стрілка вгору
 je arrow_up
 cmp ah, 48h                 ; Стрілка вниз
 je arrow_down
 cmp al, 0Dh                 ; Enter
 je enter_
 cmp al, 1Bh                 ; ESC
 je escape
 jmp input_loop_1            ; Повторення циклу
arrow_down:
 mov al, [CURRENT_ROW]       ; Вибір рядка
 cmp al, 1                   ; Перевірка на максимум
 je input_loop_1             ; Вихід, якщо максимум
 dec al
 mov [CURRENT_ROW], al       ; Зміна поточного рядка
 call drawCurrent            ; Виведення на екран поточного рядка
 jmp input_loop_1
arrow_up:
 mov al, [CURRENT_ROW]       ; Вибір рядка
 cmp al, MENU_ITEMS          ; Перевірка на максимум
 je input_loop_1             ; Вихід, якщо максимум
 inc al
 mov [CURRENT_ROW], al       ; Зміна поточного рядка
 call drawCurrent            ; Виведення на екран поточного рядка
 jmp input_loop_1
enter_:
 call procChooser            ; Виклик процедури, яка викликає процедури
 jmp input_loop_1
escape:                      ; Вихід з программи
 mov ah, 4Ch
 int 21h
 
 M_popRegisters
 ret                         ; Повернення з процедури
ENDP inputChecker            ; Кінець процедури
;------------------------------------------------------------------------------
PROC procChooser             ; Процедура для виклику необхідної процедури
 M_pushRegisters

 mov al, [CURRENT_ROW]       ; Перевірка обраного рядка
 cmp al, 1
 je item_1
 cmp al, 2
 je item_2
 cmp al, 3
 je item_3

item_1:                      ; Перший пункт меню
 lea bp, [CREATORS]
 M_drawOut 
 jmp proc_chooser_end
item_2:                      ; Другий пункт меню
 call sound
 jmp proc_chooser_end
item_3:                      ; Третій пункт меню
 call calculate
 jmp proc_chooser_end
 
proc_chooser_end:
 M_popRegisters
 ret                         ; Повернення з процедури
ENDP procChooser             ; Кінець процедури
;------------------------------------------------------------------------------
PROC sound
 M_pushRegisters

 in al, 61h                  ; Отримуємо стан динаміка
 push ax                     ; Зберігаємо стан динаміка
 or al, 00000011B            ; Змінюємо стан динаміка на ввімкнений динамік
 out 61h, al                 ; Занесення стану динаміка
 mov al, FREQUENCY           ; Встановлюємо частоту
 out 42h, al                 ; Вмикаємо таймер, який буде подавати імпульси на динамік на вказаній частоті
 call wait_time              ; Викликаємо процедуру очікування
 pop ax                      ; Повертаємо стан динаміка
 and al, 11111100B           ; Змінюємо стан динаміка на вимкнений динамік
 out 61h, al                 ; Занесення стану динаміка

 M_popRegisters
 ret                         ; Повернення з процедури
ENDP sound                   ; Кінець процедури
;------------------------------------------------------------------------------
PROC wait_time               ; Процедура очікування, проходження за двома циклами
 M_pushRegisters

 mov cx, TIME
 
loop1:             	  
 push cx	             
 mov cx, TIME
 loop2:
  loop loop2
 pop cx
 loop loop1

 M_popRegisters
 ret                         ; Повернення з процедури
ENDP wait_time               ; Кінець процедури
;------------------------------------------------------------------------------
PROC calculate               ; Процедура, що обчислює вираз ((a1-a2)*a3*a4+a5), де a1=-1, a2=1, a3=2, a4=2, a5=3, та виводить його на екран
 mov al, [a1]                ; Запис а1 до al
 mov ah, [a2]                ; Запис а2 до bh
 sub al, ah                  ; al - ah, результат в al
 mov ah, [a3]                ; Запис а3 до ah
 imul ah                     ; ah * al, результат в ax
 mov ah, [a4]                ; Запис а4 до bx
 imul ah                     ; ah * al, результат в ax
 mov bx, [a5]                ; Запис а5 до bx
 add ax, bx                  ; ax + bx, результат в ax

 mov bx, ax                  ; Заносимо значення ax до bx
 neg bx                      ; Змінюємо знак в регістрі bx
 cmp ax, bx                  ; Порівнюємо значення в ax та bx
 jb outer

minus:
 mov ax, bx                  ; Беремо додатнє значення
 mov ah, '-'                 ; Запис знака "-"
 jmp outer                   ; Вихід
outer:
 add al, 30h                                     ; Для вивіду у ASCII
 mov [EQUATION+EQUATION_SIZE], ah                ; Занесення значення для виводу
 mov [EQUATION+EQUATION_SIZE+1], al              ; Занесення значення для виводу
 lea bp, [EQUATION]
 
 M_drawOut
 ret                         ; Повернення з процедури
ENDP calculate               ; Кінець процедури
;------------------------------------------------------------------------------
Start:
;------------------------------------------------------------------------------
 mov ax, @data               ; Ініціалізуємо сегмент даних
 mov ds, ax
 mov es, ax
;------------------------------------------------------------------------------
 mov al, 1                   ; Ініціалізуємо таймер
 out 42h, al
;------------------------------------------------------------------------------
 call clearScreen            ; Виклик очищення екрану
 call drawMenu               ; Виклик відображення меню
 call drawCurrent            ; Виклик виведення на екран поточного рядка
 lea bp, [HELP_OUT]          ; Виведення тексту-помічника
 M_drawOut
 call inputChecker           ; Виклик зчитування з клавіатури та обробки

 mov ah, 4ch
 int 21h
;------------------------------------------------------------------------------
end Start