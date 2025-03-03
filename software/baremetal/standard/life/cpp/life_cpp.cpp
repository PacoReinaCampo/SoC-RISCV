////////////////////////////////////////////////////////////////////////////////
//                                            __ _      _     _               //
//                                           / _(_)    | |   | |              //
//                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
//               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
//              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
//               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
//                  | |                                                       //
//                  |_|                                                       //
//                                                                            //
//                                                                            //
//              RISC-V CPU                                                    //
//              Hello World                                                   //
//              Software                                                      //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////

/* Copyright (c) 2017-2018 by the author(s)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * =============================================================================
 * Author(s):
 *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
 */

#include <stdio.h>
#include <stdlib.h>

#define ROWS 20
#define COLS 20

#define GETCOL(c) (c%COLS)
#define GETROW(c) (c/COLS)

#define D_LEFT(c)   ((GETCOL(c) == 0) ? (COLS-1) :  -1)
#define D_RIGHT(c)  ((GETCOL(c) == COLS-1) ? (-COLS+1) :  1)
#define D_TOP(c)    ((GETROW(c) == 0) ? ((ROWS-1) * COLS) : -COLS)
#define D_BOTTOM(c) ((GETROW(c) == ROWS-1) ? (-(ROWS-1) * COLS) : COLS)

typedef struct _cell {
  struct _cell* neighbour[8];
  char curr_state;
  char next_state;
} cell;

typedef struct {
  int rows;
  int cols;
  cell* cells;
} world;

void evolve_cell(cell* c) {
  int count=0, i;
  for (i=0; i<8; i++) {
    if (c->neighbour[i]->curr_state) count++;
  }
  if (count == 3 || (c->curr_state && count == 2)) c->next_state = 1;
  else c->next_state = 0;
}

void update_world(world* w) {
  int nrcells = w->rows * w->cols, i;
  for (i=0; i<nrcells; i++) {
    evolve_cell(w->cells+i);
  }
  for (i=0; i<nrcells; i++) {
    w->cells[i].curr_state = w->cells[i].next_state;
    if (!(i%COLS)) printf("\n");
    printf("%c",w->cells[i].curr_state ? '*' : ' ');
  }
}

world* init_world() {
  world* result = (world*)malloc(sizeof(world));
  result->rows = ROWS;
  result->cols = COLS;
  result->cells = (cell*)malloc(sizeof(cell) * COLS * ROWS);

  int nrcells = result->rows * result->cols, i;

  for (i = 0; i < nrcells; i++) {
    cell* c = result->cells + i;

    c->neighbour[0] = c+D_LEFT(i);
    c->neighbour[1] = c+D_RIGHT(i);
    c->neighbour[2] = c+D_TOP(i);
    c->neighbour[3] = c+D_BOTTOM(i);
    c->neighbour[4] = c+D_LEFT(i)   + D_TOP(i);
    c->neighbour[5] = c+D_LEFT(i)   + D_BOTTOM(i);
    c->neighbour[6] = c+D_RIGHT(i)  + D_TOP(i);
    c->neighbour[7] = c+D_RIGHT(i)  + D_BOTTOM(i);

    c->curr_state = rand() % 2;
  }
  return result;
}

int main() {
  srand(3);
  world* w = init_world();
  
  while (1) {
    system("clear");
    update_world(w);
    getchar();
  }
}
