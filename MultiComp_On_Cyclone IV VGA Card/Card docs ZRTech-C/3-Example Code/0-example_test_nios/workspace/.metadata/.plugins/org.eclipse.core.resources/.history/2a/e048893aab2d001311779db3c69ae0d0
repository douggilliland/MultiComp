/*************************************************************************
* Copyright (c) 2009 Altera Corporation, San Jose, California, USA.      *
* All rights reserved. All use of this software and documentation is     *
* subject to the License Agreement located at the end of this file below.*
*************************************************************************/
/******************************************************************************
 *
 * Description
 * ************* 
 * A program which provides a means to test most of the devices on a Nios
 * Development Board.  The devices covered in this test are, as follows:
 *  - Seven Segment Display
 *  - The D0-D7 LEDs (located just under the FPGA on most Development boards).
 *      The classic "walking" LED will be displayed on these LEDs.
 *  - UART test 
 *      Tests UART functionality for the UART defined as STDOUT.
 *      * JTAG UART device.
 *  - The LCD Display
 *      Displays a short message on the LCD Display.
 *  - Buttons/Switches (SW0-SW3 on the Development boards, located right
 *    under the FPGA.
 *      This detects button presses, in a tight loop, and returns any
 *      non-zero value.  
 *  
 * Requirements
 * **************
 * This program requires the following devices to be configured:
 *   an LED PIO named 'led_pio',
 *   a Seven Segment Display PIO named 'seven_seg_pio',
 *   an LCD Display named 'lcd_display',
 *   a Button PIO named 'button_pio',
 *   a JTAG connection (to test the JTAG UART functionality)
 *
 * 
 * Peripherals Exercised by SW
 * *****************************
 * LEDs
 * Seven Segment Display
 * LCD
 * Buttons (SW0-SW3)
 * JTAG UART
 * 
 *
 * Software Files
 * ****************
 * board_diagnostics.c - This file.
 *    - Implements a top level menu allowing the user to choose which 
 * board components to test.
 * 
 * board_diagnostics.h
 *    - A file containing the common includes and definitions for
 * use within this code.
 * 
 */
 
#include "board_diag.h"

/* Declare one global variable to capture the output of the buttons (SW0-SW3),
 * when they are pressed.
 */
 
volatile int edge_capture;

/* *********************************************************************
 * Menu related functions 
 * *********************************************************************
 * A valid STDOUT device must be defined for these functions to work.
 *  - a JTAG UART is the recommended STDOUT device.
 */

/* void MenuBegin( char *title )
 * 
 * Function to set the Menu "header".
 */

static void MenuBegin( char *title )
{
  printf("\n\n");
  printf("----------------------------------\n");
  printf("Nios II Board Diagnostics\n");
  printf("----------------------------------\n");
  printf(" %s\n",title);
}

/**********************************************************************
 * static void MenuItem( char letter, char *string )
 * 
 * Function to define a menu entry.
 *  - Maps a character (defined by 'letter') to a description string
 *    (defined by 'string').
 *
 **********************************************************************/

static void MenuItem( char letter, char *name )
{
  printf("     %c:  %s\n" ,letter, name);
}

/******************************************************************
*  Function: GetInputString
*
*  Purpose: Parses an input string for the character '\n'.  Then
*           returns the string, minus any '\r' characters it 
*           encounters.
*
******************************************************************/
void GetInputString( char* entry, int size, FILE * stream )
{
  int i;
  int ch = 0;
  
  for(i = 0; (ch != '\n') && (i < size); )
  {
    if( (ch = getc(stream)) != '\r')
    {
      entry[i] = ch;
      i++;
    }
  }
}

/* void MenuEnd(char lowLetter, char highLetter)
 * 
 * Function which defines the menu exit/end conditions.
 *  In this context, the character 'q' always means 'exit'.
 *    The code grabs input from STDIN (via the GetInputString function)
 *    and continues until either a 'q' or a character outside of the 
 *    range, enclosed by 'lowLetter' and 'highLetter', is reached.
 */

static int MenuEnd( char lowLetter, char highLetter )
{
  static char entry[4];
  static char ch;

  printf("     q:  Exit\n");
  printf("----------------------------------\n");
  printf("\nSelect Choice (%c-%c): [Followed by <enter>]",lowLetter,highLetter);
  
  GetInputString( entry, sizeof(entry), stdin );
  if(sscanf(entry, "%c\n", &ch))
  {
    if( ch >= 'A' && ch <= 'Z' )
      ch += 'a' - 'A';
    if( ch == 27 )
      ch = 'q';        
  }
  return ch;
}

#ifdef JTAG_UART_NAME

/*******************************************************************************
 * 
 * static void DoJTAGUARTMenu( void )
 * 
 * Generates the JTAG UART testing menu.
 * 
 ******************************************************************************/

static void DoJTAGUARTMenu( void )
{
  static char ch;  
  
  while (1)
  {
    MenuBegin( "JTAG UART Menu" );
    MenuItem( 'a', "Send Lots" );
    MenuItem( 'b', "Receive Chars" );
    ch = MenuEnd('a', 'b');

    switch (ch)
    {
      MenuCase('a', UARTSendLots);
      MenuCase('b', UARTReceiveChars);
    }
    
    if (ch == 'q')
    {
      break;
    }
  }
}

#endif

#ifdef SEVEN_SEG_PIO_NAME

/*******************************************************************************
 * 
 * static void DoSevenSegMenu( void )
 * 
 * Generates the Seven Segment Display menu.
 * 
 ******************************************************************************/

static void DoSevenSegMenu( void )
{
  static char ch;

  while(1)
  {
    MenuBegin("Seven Segment Menu");
    MenuItem('a', "Count From 0 to FF.");
    MenuItem('b', "Control Individual Segments.");
    ch = MenuEnd('a', 'b');
  
    switch(ch)
    {
      MenuCase('a', SevenSegCount);
      MenuCase('b', SevenSegControl);
    }
    
    if ( ch == 'q' )
    {
      break;
    }
  }
}

#endif

/*******************************************************************************
 * 
 * Generates the top level menu for this diagnostics program.
 * 
 ******************************************************************************/

static char TopMenu( void )
{
  static char ch;
  
  /* Output the top-level menu to STDOUT */

  while (1)
  {
    MenuBegin("Main Menu");
#ifdef LED_PIO_NAME
    MenuItem( 'a', "Test LEDs" );
#endif
#ifdef LCD_DISPLAY_NAME
    MenuItem( 'b', "LCD Display Test");
#endif
#ifdef BUTTON_PIO_NAME
    MenuItem( 'c', "Button/Switch Test");
#endif
#ifdef SEVEN_SEG_PIO_NAME
    MenuItem( 'd', "Seven Segment Menu" );
#endif
#ifdef JTAG_UART_NAME
    MenuItem( 'e', "JTAG UART Menu" );
#endif  
    ch = MenuEnd('a', 'e');

  
    switch(ch)
    {
#ifdef LED_PIO_NAME
      MenuCase('a',TestLEDs);
#endif
#ifdef LCD_DISPLAY_NAME
      MenuCase('b',TestLCD);
#endif
#ifdef BUTTON_PIO_NAME
      MenuCase('c',TestButtons);
#endif
#ifdef SEVEN_SEG_PIO_NAME
      MenuCase('d',DoSevenSegMenu);
#endif
#ifdef JTAG_UART_NAME
      MenuCase('e',DoJTAGUARTMenu);
#endif
      case 'q':	break;
      default:	printf("\n -ERROR: %c is an invalid entry.  Please try again\n", ch); break;
    }
    
    if (ch == 'q' )
      break;
  }
  return( ch );
}

/* ********************************************************************
 * 
 * Peripheral specific functions.
 * 
 * ********************************************************************/

#ifdef LED_PIO_NAME

/* 
 * static void TestLEDs(void)
 * 
 * This function tests LED functionality.
 * It exits when the user types a 'q'.
 */

static void TestLEDs(void)
{
  volatile alt_u8 led;
  static char ch;
  static char entry[4];
  
  /* Turn the LEDs on. */
  led = 0xff;
  IOWR_ALTERA_AVALON_PIO_DATA(LED_PIO_BASE, led);
  printf( "\nAll LEDs should now be on.\n" );
  printf( "\tPlease press 'q' [Followed by <enter>] to exit this test.\n" );
  
  /* Get the input string for exiting this test. */
  do {
    GetInputString( entry, sizeof(entry), stdin);
    sscanf( entry, "%c\n", &ch );
  } while ( ch != 'q' );
  
  /* Turn the LEDs off and exit. */
  led = 0x0;
  IOWR_ALTERA_AVALON_PIO_DATA(LED_PIO_BASE, led);
  printf(".....Exiting LED Test.\n");
}

#endif
#ifdef LCD_DISPLAY_NAME

/*******************************************************************************
 * 
 * static void TestLCD( void )
 * 
 * Tests the LCD by printing some simple output to each line.
 * 
 ******************************************************************************/

static void TestLCD( void )
{
  FILE *lcd;
  static char ch;
  static char entry[4];
  
  lcd = fopen("/dev/lcd_display", "w");
  
  /* Write some simple text to the LCD. */
  if (lcd != NULL )
  {
    fprintf(lcd, "\nThis is the LCD Display.\n");
    fprintf(lcd, "If you can see this, your LCD is functional.\n");
  }
  printf("\nIf you can see messages scrolling on the LCD Display, then it is functional!\n");
  printf( "\tPlease press 'q' [Followed by <enter>] to exit this test.\n" );
  
  /* Get the input string for exiting this test. */
  do {
    GetInputString( entry, sizeof(entry), stdin);
    sscanf( entry, "%c\n", &ch );
  } while ( ch != 'q' );

  /* Send the command sequence to clear the LCD. */
  if (lcd != NULL )
  {
    fprintf(lcd, "%c%s", ESC, CLEAR_LCD_STRING);
  }
  fclose( lcd );

  return;
}

#endif

#ifdef BUTTON_PIO_NAME

/*********************************************
 * Button/Switch PIO Functions                      
 *********************************************/

/*******************************************************************
 * static void handle_button_interrupts( void* context, alt_u32 id)*
 *                                                                 *  
 * Handle interrupts from the buttons.                             *
 * This interrupt event is triggered by a button/switch press.     *
 * This handler sets *context to the value read from the button    *
 * edge capture register.  The button edge capture register        *
 * is then cleared and normal program execution resumes.           *
 * The value stored in *context is used to control program flow    *
 * in the rest of this program's routines.                         *
 *                                                                 *
 * Provision is made here for systems that might have either the   *
 * legacy or enhanced interrupt API active, or for the Nios II IDE *
 * which does not support enhanced interrupts. For systems created *
 * using the Nios II softawre build tools, the enhanced API is     *
 * recommended for new designs.                                    *
 ******************************************************************/
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void handle_button_interrupts(void* context)
#else
static void handle_button_interrupts(void* context, alt_u32 id)
#endif
{
  /* Cast context to edge_capture's type.
   * It is important to keep this volatile,
   * to avoid compiler optimization issues.
   */
  volatile int* edge_capture_ptr = (volatile int*) context;
  /* Store the value in the Button's edge capture register in *context. */
  *edge_capture_ptr = IORD_ALTERA_AVALON_PIO_EDGE_CAP(BUTTON_PIO_BASE);
  /* Reset the Button's edge capture register. */
  IOWR_ALTERA_AVALON_PIO_EDGE_CAP(BUTTON_PIO_BASE, 0);
  
  /* 
   * Read the PIO to delay ISR exit. This is done to prevent a spurious
   * interrupt in systems with high processor -> pio latency and fast
   * interrupts.
   */
  IORD_ALTERA_AVALON_PIO_EDGE_CAP(BUTTON_PIO_BASE);
}

/* Initialize the button_pio. */

static void init_button_pio()
{
  /* Recast the edge_capture pointer to match the alt_irq_register() function
  * prototype. */
  void* edge_capture_ptr = (void*) &edge_capture;
  /* Enable all 4 button interrupts. */
  IOWR_ALTERA_AVALON_PIO_IRQ_MASK(BUTTON_PIO_BASE, 0xf);
  /* Reset the edge capture register. */
  IOWR_ALTERA_AVALON_PIO_EDGE_CAP(BUTTON_PIO_BASE, 0x0);
  
  /* 
   * Register the interrupt handler. 
   * Provision is made here for systems that might have either the 
   * legacy or enhanced interrupt API active, or for the Nios II IDE
   * which does not support enhanced interrupts. For systems created using
   * the Nios II softawre build tools, the enhanced API is recommended
   * for new designs.
   */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
  alt_ic_isr_register(BUTTON_PIO_IRQ_INTERRUPT_CONTROLLER_ID, BUTTON_PIO_IRQ, 
    handle_button_interrupts, edge_capture_ptr, 0x0);
#else
  alt_irq_register( BUTTON_PIO_IRQ, edge_capture_ptr, 
    handle_button_interrupts);
#endif
}

/* Tear down the button_pio. */

static void disable_button_pio()
{
  /* Disable interrupts from the button_pio PIO component. */
  IOWR_ALTERA_AVALON_PIO_IRQ_MASK(BUTTON_PIO_BASE, 0x0);
  /* Un-register the IRQ handler by passing a null handler. */
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
  alt_ic_isr_register(BUTTON_PIO_IRQ_INTERRUPT_CONTROLLER_ID, BUTTON_PIO_IRQ, 
    NULL, NULL, NULL);
#else
  alt_irq_register( BUTTON_PIO_IRQ, NULL, NULL );
#endif
}

/*******************************************************************************
 * 
 * static void TestButtons( void )
 * 
 * Generates a loop that exits when all buttons/switches have been pressed, 
 * at least, once.
 * 
 * NOTE:  Buttons/Switches are not debounced.  A single press of a
 * button may result in multiple messages.
 * 
 ******************************************************************************/


static void TestButtons( void )
{
  alt_u8 buttons_tested;
  alt_u8 all_tested;
  /* Variable which holds the last value of edge_capture to avoid 
   * "double counting" button/switch presses
   */
  int last_tested;
  /* Initialize the Buttons/Switches (SW0-SW3) */
  init_button_pio();
  /* Initialize the variables which keep track of which buttons have been tested. */
  buttons_tested = 0x0;
  all_tested = 0xf;

  /* Initialize edge_capture to avoid any "false" triggers from
   * a previous run.
   */
   
  edge_capture = 0;
  
  /* Set last_tested to a value that edge_capture can never equal
   * to avoid accidental equalities in the while() loop below.
   */
    
  last_tested = 0xffff;

  /* Print a quick message stating what is happening */
  
  printf("\nA loop will be run until all buttons/switches have been pressed.\n\n");
  printf("\n\tNOTE:  Once a button press has been detected, for a particular button,\n\tany further presses will be ignored!\n\n");
  
  /* Loop until all buttons have been pressed.
   * This happens when buttons_tested == all_tested.
   */
  
  while (  buttons_tested != all_tested )
  { 
    if (last_tested == edge_capture)
    {
      continue;
    }
    else
    {
      last_tested = edge_capture;
      switch (edge_capture)
      {
        case 0x1:
          if (buttons_tested & 0x1)
          {
            continue;
          }
          else
          {
            printf("\nButton 1 (SW0) Pressed.\n");
            buttons_tested = buttons_tested | 0x1;
          } 
          break;
        case 0x2:
          if (buttons_tested & 0x2)
          {
            continue;
          } 
          else
          {
            printf("\nButton 2 (SW1) Pressed.\n");
            buttons_tested = buttons_tested | 0x2;
          }
          break;
        case 0x4:
          if (buttons_tested & 0x4)
          {
            continue;
          }
          else
          {
            printf("\nButton 3 (SW2) Pressed.\n");
            buttons_tested = buttons_tested | 0x4;
          }
          break;
        case 0x8:
          if (buttons_tested & 0x8)
          {
            continue;
          }
          else
          {
            printf("\nButton 4 (SW3) Pressed.\n");
            buttons_tested = buttons_tested | 0x8;
          }
          break;
      }
    }
  }
  /* Disable the button pio. */
  disable_button_pio();

  printf ("\nAll Buttons (SW0-SW3) were pressed, at least, once.\n");
  usleep(2000000);
  return;
}

#endif

#ifdef SEVEN_SEG_PIO_NAME

/*********************************************
 * Seven Segment Functions
 *********************************************/

/*********************************************
 * static void sevenseg_set_hex(alt_u8 hex)
 * 
 * Function which encodes the value passed in by
 * the variable 'hex' into what is displayed on
 * the Seven Segment Display.
 *********************************************/
 
static void sevenseg_set_hex(alt_u8 hex)
{
  static alt_u8 segments[16] = {
    0x81, 0xCF, 0x92, 0x86, 0xCC, 0xA4, 0xA0, 0x8F, 0x80, 0x84, /* 0-9 */
    0x88, 0xE0, 0xF2, 0xC2, 0xB0, 0xB8 };                       /* a-f */

  alt_u32 data = segments[hex & 15] | (segments[(hex >> 4) & 15] << 8);

  IOWR_ALTERA_AVALON_PIO_DATA(SEVEN_SEG_PIO_BASE, data);
}

/*******************************************
 * static void SevenSegCount( void )
 * 
 * Displays from 0 to FF on the Seven Segment Display with
 * a 0.25s count delay implemented in a for loop.
 *******************************************/
 
static void SevenSegCount( void )
{
  alt_u32 count;
  for (count = 0; count <= 0xff; count++)
  {
    sevenseg_set_hex( count );
    usleep(50000);
  }
}

/******************************************
 * static void SevenSegControl(void)
 * 
 * Displays selected Seven Segment segments.
 * 
 ******************************************/

static void SevenSegControl(void)
{
  char entry[4];
  alt_32 bits;
  alt_32 keyBit;
  static char ch;
  
  /* Turn all segments off at start of test. */
  bits = 0xffff;
  IOWR_ALTERA_AVALON_PIO_DATA(SEVEN_SEG_PIO_BASE, bits);

  printf("\n");
  printf("\n");
  printf("         +-A--+     +-a--+\n");
  printf("         |    |     |    |\n");
  printf("         F    B     f    b\n");
  printf("         |    |     |    |\n");
  printf("         +-G--+     +-g--+\n");
  printf("         |    |     |    |\n");
  printf("         E    C     e    c\n");
  printf("         |    |     |    |\n");
  printf("         +-D--+ (H) +-d--+ (h)\n");
  printf("\n");
  printf("Press 'q' [Followed by <enter>] to exit this test.\n");
  
  do
  {
    /* Get terminal input. */
    GetInputString( entry, sizeof(entry), stdin);
    sscanf( entry, "%c\n", &ch );
    /* SSD pattern algorithm. */
    keyBit = 0;
    if(ch >= 'a' && ch <= 'g')
      keyBit = 1 << ('g' - ch);
    else if(ch == 'h')
      keyBit = 1 << 7;
    else if(ch >= 'A' && ch <= 'G')
      keyBit = 1 << ('G' - ch + 8);
    else if(ch == 'H')
      keyBit = 1 << 15;
    bits ^= keyBit;
    IOWR_ALTERA_AVALON_PIO_DATA(SEVEN_SEG_PIO_BASE, bits);
  }
  while( ch != 'q' );
}

#endif

#ifdef JTAG_UART_NAME

/****************************************************
 * UART Functions
 * 
 ****************************************************/

/****************************************************
 * static void UARTSendLots( void )
 * 
 * Function which sends blocks/lots of text over the UART
 * 
 * For now, it is hardcoded to send 100 lines with 80 
 * characters per line.
 * 
 ****************************************************/

static void UARTSendLots( void )
{
  char entry[4];
  static char ch;
  int i,j;
  int mix = 0;

  printf("\n\nPress character (and <enter>), or <space> (and <enter>) for mix: ");
  GetInputString( entry, sizeof(entry), stdin);
  sscanf( entry, "%c\n", &ch );
  printf("%c\n\n",ch);
  
  /* Don't print unprintables! */
  if(ch < 32)
    ch = '.';
    
  /* Check to see if the character is a space (for "mix" of chars). */
  
  if (ch == ' ')
  {
    mix = 1;
  }
  
  /* The loop that sends the block of text. */
  
  for(i = 0; i < 100; i++)
  {
    for(j = 0; j < 80; j++)
    {
      if(mix)
      {
        ch++;
        if(ch >= 127)
          ch = 33;
      }
      printf("%c", ch);
    }
    printf("\n");
  }
  printf("\n");
}

/*************************************************
 * 
 * static void UARTReceiveChars(void)
 * 
 * Typed characters will be repeated on the terminal connection.
 * 
 * Entering 'q' will end the session.
 *
 ************************************************/

static void UARTReceiveChars(void)
{
  static char entry[4];
  static char ch;
  static char chP;

  printf("\n\nEnter a character (followed by <enter>); \n\tPress 'q' (followed by <enter>) to exit this test.\n\n");
  
  do
  {
    GetInputString( entry, sizeof(entry), stdin );
    sscanf( entry, "%c\n", &ch );
    chP = ch >= 32 ? ch : '.';
    printf("\'%c\' 0x%02x %d\n",chP,ch,ch);
  }
  while( ch != 'q' );
}

#endif

int main()
{
  /* Declare variable for received character. */
  int ch;
  
  while (1)
  {
    ch = TopMenu();
    if (ch == 'q')
    {
      printf( "\nExiting from Board Diagnostics.\n");
      /* Send EOT to nios2-terminal on the other side of the link. */
      printf( "%c", EOT );
      break;
    }
  }
  return( 0 );
}
/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
