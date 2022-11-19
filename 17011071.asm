SSEG		SEGMENT PARA STACK 'STACK'
			DW 50 DUP(?)
SSEG    	ENDS

DSEG		SEGMENT PARA 'DATA'
K			DW 0
INDIS       DW 0
YENI_DEGER  DW 0
N       	DW 0
DEGER   	DW 100 DUP(0)
LINK    	DW 100 DUP(-5)
CR      	EQU 13
LF      	EQU 10
HT			EQU 9
ANA_MENU    DB CR, LF, 'ALT MENU1 -> 1  ', 'ALT MENU2 -> 2  ', 'ALT MENU3 -> 3 ', 'CIKIS -> 4', CR, LF, 0
HATA		DB CR, LF, 'Sayi vermediniz, yeniden giriş yapiniz!  ', CR, LF, 0
MSJ0        DB CR, LF, 'Eleman sayisini giriniz: ', 0 
MSJ3		DB CR, LF, 'Eklemek istediginiz degerler -32768 ile 32767 araliginda olmalidir!', CR, LF, 0
MSJ1  		DB CR, LF, 'Elemanlari giriniz: ', 0
MSJ2        DB CR, LF, 'Eklemek istediginiz yeni degeri giriniz: ', 0
MSJ4		DB CR, LF, '17011071 - Hatice Demir', 0
BOSLUK		DB HT, 0
NEWLINE     DB CR, LF, 0
DSEG    	ENDS

CSEG    	SEGMENT PARA 'CODE'
			ASSUME CS:CSEG, DS:DSEG, SS:SSEG
		
ANA     	PROC FAR
			PUSH DS 
			XOR AX, AX
			PUSH AX
			MOV AX, DSEG
			MOV DS, AX
			
			CALL SIL
MENU_SEC:	MOV AX, OFFSET MSJ4
			CALL PUT_STR
			MOV AX, OFFSET ANA_MENU
			CALL PUT_STR ;MENU0'ı göster
			CALL GETN ;MENU seçimi yapılır
			CMP AX, 1
			JZ ALT_MENU_1
			CMP AX, 2
			JZ ALT_MENU_2
			CMP AX, 3
			JZ ALT_MENU_3
			CMP AX, 4
			JMP CIKIS

ALT_MENU_1: MOV AX, OFFSET MSJ0
			CALL PUT_STR
			CALL GETN
			MOV N, AX ;Kullanıcıdan alınan eleman sayısı diğer fonksiyonlarda da kullanılabilsin diye N değişkenine atılır
			MOV CX, AX
			XOR SI, SI
			MOV AX, OFFSET MSJ3
			CALL PUT_STR
			MOV AX, OFFSET MSJ1
			CALL PUT_STR
OKU:		CALL GETN ;Elemanlar teker teker alınır ve DEGER dizisine yerleştirilir
			MOV DEGER[SI], AX
			ADD SI, 2
			LOOP OKU
			CALL LINKED_LIST ;LINKED_LIST fonksiyonu çağrılır ve linkler oluşturulur
			CALL SIL	
			JMP MENU_SEC ;Kullanıcı tekrar menü seç ekranına yönlendirilir

ALT_MENU_2: MOV CX, N
			XOR SI, SI
			MOV AX, OFFSET NEWLINE
			CALL PUT_STR			
YAZDIR:		MOV AX, DEGER[SI] ;DEGER dizisindeki her bir eleman AX registerı üzerinden ekrana yazdırılır
			CALL PUTN
			MOV AX, OFFSET BOSLUK
			CALL PUT_STR
			ADD SI, 2
			LOOP YAZDIR
			MOV AX, OFFSET NEWLINE
			CALL PUT_STR
			MOV CX, N
			XOR SI, SI
YAZDIR2:	MOV AX, LINK[SI] ;LINK dizisindeki her bir link AX registerı üzerinden ekrana yazdırılır
			CALL PUTN
			MOV AX, OFFSET BOSLUK
			CALL PUT_STR
			ADD SI, 2
			LOOP YAZDIR2
			MOV AX, OFFSET NEWLINE
			CALL PUT_STR
			JMP MENU_SEC ;Kullanıcı tekrar menü seç ekranına yönlendirilir

ALT_MENU_3: MOV AX, OFFSET MSJ2
			CALL PUT_STR
			CALL GETN
			MOV YENI_DEGER, AX ;Diziye eklenecek yeni değer YENI_DEGER değişkenine atılır
			PUSH BX
			PUSH DX
			PUSH SI
			MOV AX, N
			MOV BX, 2
			XOR DX, DX
			MUL BX
			MOV SI, AX
			MOV DX, YENI_DEGER
			MOV DEGER[SI], DX ;YENI_DEGER dizinin sonuna eklenir 
			INC N ;Dizinin eleman sayısı yeni eklenen değerden dolayı bir artırılır
			POP SI
			POP DX
			POP BX
			CALL LINKED_LIST ;LINKED_LIST fonksiyonu çağrılarak yeni eklenen değerle birlikte linkler güncellenir
			JMP MENU_SEC ;Kullanıcı tekrar menü seç ekranına yönlendirilir
			
CIKIS:		RETF
ANA     	ENDP

LINKED_LIST PROC NEAR
			PUSH AX ;Kullanılan registerlar stackte muhafaza edilir
			PUSH BX
			PUSH CX
			PUSH DX
			PUSH SI
			PUSH DI
			
			MOV CX, N
			XOR SI, SI
			MOV DX, -5
ETIKET6:	MOV LINK[SI], DX ;Başlangıçta LINK dizisinin tüm elemanları -5 yapılır
			INC SI
			INC SI
			LOOP ETIKET6
			MOV DI, 0
			MOV INDIS, DI
			MOV AX, DEGER[DI] ;AX içinde DEGER dizisinin ilk elemanı var
			MOV CX, N
			DEC CX
			MOV SI, 2 
ENBUYUK:	CMP AX, DEGER[SI] ;ENBUYUK döngüsünün sonunda AX içinde dizinin en büyük elemanı var
			JGE ETIKET0
			MOV INDIS, SI ;SI'da max elemanın indisi var = I
			MOV AX, DEGER[SI]
ETIKET0:	ADD SI, 2
			LOOP ENBUYUK
			MOV SI, INDIS ;INDIS değişkeninde max elemanın indisi var
			MOV DX, -1
			MOV LINK[SI], DX ;En büyük elemanın linki -1 yapılır
			MOV CX, N
			DEC CX
DONGU:		MOV DI, 0
			MOV DX, -5
ETIKET2:	CMP LINK[DI], DX ;DEGER dizisi içinde linklenmemiş ilk elemanın indisi DI içinde 
			JZ ETIKET1
			ADD DI, 2
			JMP ETIKET2
ETIKET1:	MOV AX, DEGER[DI] ;AX içinde linklenmemiş ilk eleman var
			MOV INDIS, DI
			MOV DX, 2
			MOV K, DX
			PUSH AX
			PUSH BX
			MOV BX, 2
			XOR DX, DX
			MOV AX, N
			MUL BX
			DEC AX
			DEC AX
			MOV DX, AX ;DX->2N-2
			POP BX
			POP AX			
ETIKET3:	CMP K, DX
			JA ETIKET4
			MOV BX, DI
			ADD BX, K
			CMP BX, DX
			JA ETIKET4
			CMP AX, DEGER[BX] ;AX ile AX'ten sonraki elemanlar karşılaştırılır
			JGE ETIKET5
			PUSH DX
			MOV DX, -5
			CMP LINK[BX], DX ;Eğer sıradaki eleman linklenmemiş ve AX'ten büyükse AX içine yerleştirilir
			POP DX
			JNZ ETIKET5
			MOV AX, DEGER[BX]
			MOV INDIS, BX ;INDIS değişkenine de bu elemanın indisi yerleştirilir
ETIKET5:	INC K
			INC K ;K ile bir sonraki elemanla AX karşılaştırılır
			JMP ETIKET3
ETIKET4:    PUSH DI
			MOV DI, INDIS
			SHR SI, 1 ;Dizi word tipinde olduğu için indis 2'ye bölünür
			MOV LINK[DI], SI ;Linklenmemiş bir sonraki elemana bir önceki en büyük elemanın indisi yerleştirilir
			MOV SI, INDIS ;Yeni bulunan en büyük değerin indisi SI içinde saklanır
			POP DI
			LOOP DONGU
			
			POP DI
			POP SI
			POP DX
			POP CX
			POP BX
			POP AX	
			RET
LINKED_LIST ENDP

GETC        PROC NEAR ;Klavyeden basılan karakteri AL yazmacına alır ve ekranda gösterir. İşlem sonucunda sadece AL etkilenir.
			MOV AH, 1H
			INT 21H
			RET
GETC 		ENDP			

GETN		PROC NEAR 
			PUSH BX
			PUSH CX
			PUSH DX
GETN_START: MOV DX, 1 ;Sayının şimdilik + olduğu varsayılır
			XOR BX, BX ;Okuma yapmadı hane 0 olur
			XOR CX, CX ;Ara toplam değeri de 0'dır
NEW:		CALL GETC ;Klavyeden ilk değeri AL'ye oku
			CMP AL, CR
			JE FIN_READ ;Enter tuşuna basılmış ise okuma biter
			CMP AL, '-' ;AL, '-' mi geldi ?
			JNE CTRL_NUM ;Gelen 0-9 arasında bir sayı mı?
NEGATIVE:  	MOV DX, -1;- basıldı ise sayı negatif, DX=-1 olur 
			JMP NEW ;Yeni haneyi al
CTRL_NUM:   CMP AL, '0' ;Sayının 0-9 arasında olduğunu kontrol etkilenir
			JB ERROR 
			CMP AL, '9'
			JA ERROR ;Değil ise HATA mesajı verilecek
			SUB AL, '0' ;Rakam alındı, haneyi toplama dahil et
			MOV BL, AL ;BL'ye okunan haneyi koy
			MOV AX, 10 ;Haneyi eklerken *10 yapılacak
			PUSH DX ;MUL komutu DX'i bozar işaret için saklanmalı
			MUL CX ;DX:AX = AX * CX
			POP DX ;İşareti geri al
			MOV CX, AX ;CX'deki ara değer *10 yapıldı
			ADD CX, BX ;Okunan haneyi ara değere ekle
			JMP NEW ;Klavyeden yeni basılan değeri al
ERROR:		MOV AX, OFFSET HATA
			CALL PUT_STR ;HATA mesajını göster
			JMP GETN_START ;O ana kadar okunanları unut yeniden sayı almaya başla
FIN_READ:	MOV AX, CX ;Sonuç AX üzerinden dönecek
			CMP DX, 1 ;İşarete göre sayıyı ayarlamak lazım
			JE FIN_GETN
			NEG AX
FIN_GETN:   POP DX
			POP CX
			POP BX
			RET
GETN        ENDP			

PUT_C  		PROC NEAR ;AL yazmacındaki değeri ekranda gösterir. DL ve AH değişiyo. AX ve DX yazmaçlarının değerleri korumak için PUSH/POP yapılır.
			PUSH AX
			PUSH DX
			MOV DL, AL
			MOV AH, 2
			INT 21H
			POP DX
			POP AX
			RET
PUT_C        ENDP			

PUT_STR		PROC NEAR ;AX de adresi verilen sonunda 0 olan dizgeyi karakter karakter yazdırır. BX dizgeye indis olarak kullanılır. Önceki değeri saklanmalıdır.
			PUSH BX 
			MOV BX, AX ;Adresi BX'e al
			MOV AL, BYTE PTR [BX] ;AL'de ilk karakter var
PUT_LOOP:   CMP AL, 0
			JE  PUT_FIN ;0 geldi ise dizge sona erdi demek
			CALL PUT_C ;AL'deki karakteri ekrana yazar
			INC BX ;Bir sonraki karaktere geç
			MOV AL, BYTE PTR [BX]
			JMP PUT_LOOP ;Yazdırmaya devam
PUT_FIN:    POP BX
            RET
PUT_STR     ENDP

PUTN		PROC NEAR ;AX'de bulunan sayıyı onluk tabanda hane hane yazdırır. CX: Haneleri 10'a bölerek bulacağız,
			PUSH CX ;CX=10 olacak DX: 32 bölmede işleme dahil olacak. Sonucu etkilemesin diye 0 olmalı
			PUSH DX
			XOR DX, DX ;DX 32 bit bölmede sonucu etkilemesin diye 0 olmalı
			PUSH DX ;Haneleri ASCII karakter olarak yığında saklayacağız, kaç haneyi alacağımızı bilmediğimiz için yığına 0 değeri koyup onu alana kadar devam edeceğiz
			MOV CX, 10 ;CX=10
			CMP AX, 0
			JGE CALC_DIGITS
			NEG AX ;Sayı negatif ise AX pozitif yapılır
			PUSH AX ;AX sakla
			MOV AL, '-' ;İşareti ekrana yazdır
			CALL PUT_C
			POP AX ;AX'i geri al
CALC_DIGITS:DIV CX ;DX:AX = AX/CX AX=bölüm DX=kalan
			ADD DX, '0' ;Kalan değerini ASCII olarak bul
			PUSH DX ;Yığına sakla
			XOR DX, DX ;DX=0
			CMP AX, 0 ;Bölen 0 kaldı ise sayının işlenmesi bitti demek 
			JNE CALC_DIGITS ;İşlemi tekrarla
DISP_LOOP:	POP AX ;Yazılacak tüm haneler yığında. En anlamlı hane üstte en az anlamlı hane en altta ve onun altında da sona vardığımızı anlamak için konan 0 değeri var.
			CMP AX, 0 ;Sırayla değerleri yığından alalım. AX=0 olursa sona geldik demek
			JE END_DISP_LOOP
			CALL PUT_C ;AL'deki ASCII değeri yaz 
			JMP DISP_LOOP ;İşleme devam
END_DISP_LOOP:
			POP DX
			POP CX
			RET	
PUTN 		ENDP

SIL			PROC NEAR ;Ekranı temizle
			MOV CX, 0000H ;Ekranın sol üst köşesi satır/sütun adresi
			MOV DX, 184FH ;Ekranın sağ alt köşesi satır/sütun adresi
			MOV BH, 07H ;Öznitelik değeri attribute byte
			MOV AX, 0600H ;AH=06H pencereyi yukarı kaydırma 
			INT 10H ;10H numaralı kesmeyi çağır
			RET
SIL			ENDP

CSEG    	ENDS 
			END ANA	