#include "efi.h"
#include "efilib.h"
 
EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    EFI_STATUS status;
    EFI_INPUT_KEY key;
 
    /* Store the system table for future use in other functions */
    ST = SystemTable;
 
    /* Say hi */
    status = ST->ConOut->ClearScreen(ST->ConOut);
    if (EFI_ERROR(status))
    {
        return status;
    }
    status = ST->ConOut->OutputString(ST->ConOut, L"Hello World\n\r");

    if (EFI_ERROR(status))
    {
        return status;
    }
 
    /* Now wait for a kstroke before continuing, otherwise your
       message will flash off the screen before you see it.
 
       First, we need to empty the console input buffer to flush
       out any keystrokes entered before this point */
    status = ST->ConIn->Reset(ST->ConIn, FALSE);
    if (EFI_ERROR(status))
    {
        return status;
    }
 
    /* Now wait until a key becomes available.  This is a simple
       polling implementation.  You could try and use the WaitForKey
       event instead if you like */
    while ((status = ST->ConIn->ReadKeyStroke(ST->ConIn, &key)) == EFI_NOT_READY) ;
 
    return status;
}
