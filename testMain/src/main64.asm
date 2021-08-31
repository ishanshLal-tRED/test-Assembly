.data
myList DWORD 2, 3, 5, 8

.code
mainCRTStartup PROC
  mov eax, 7
  add eax, 8
  ret
mainCRTStartup ENDP

END ;specify the program's entry point