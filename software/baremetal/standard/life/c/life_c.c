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

typedef struct cell_t_ {
  struct cell_t_ *neighbours[8];
  int on;
} cell_t;

typedef struct world_t_ {
  cell_t **array;
  int width;
  int height;
  void *mem;
} world_t;

void printworld(world_t *world, FILE *pOutput) {
  int x, y;

  for(y = 0; y < world->height; y++) {
    for(x = 0; x < world->width; x++) {
      fprintf(pOutput, "%c", (world->array[y][x]).on ? 254 : ' ');
    }
    fputc((int)'\n', pOutput);
  }
  fflush(pOutput);
}

void randomizeworld(world_t *world) {
  int x, y;

  for(y = 0; y < world->height; y++) {
    for(x = 0; x < world->width; x++) {
      (world->array[y][x]).on = rand() & 1;
    }
  }
}

void updateworld(world_t *world) {
  int x, y, i, neighbours;

  for(y = 0; y < world->height; y++) {
    for(x = 0; x < world->width; x++, neighbours = 0) {
      for(i = 0; i < 8; i++)
        if((world->array[y][x].neighbours[i]) && ((world->array[y][x]).neighbours[i]->on & 1))
          neighbours++;

      if((neighbours < 2) || (neighbours > 3))
        (world->array[y][x]).on |= 2;
      else if(neighbours == 3)
        (world->array[y][x]).on |= 4;
    }
  }

  for(y = 0; y < world->height; y++) {
    for(x = 0; x < world->width; x++) {
      if(world->array[y][x].on & 4)
        world->array[y][x].on = 1;
      else if(world->array[y][x].on & 2)
        world->array[y][x].on = 0;
    }
  }
}

void destroyworld(world_t *world) {
  free(world->mem);
}

int createworld(world_t *world, int width, int height) {
  int i, j;
  unsigned long base   = sizeof(cell_t *) * height;
  unsigned long rowlen = sizeof(cell_t)   * width;

  if(!(world->mem = calloc(base + (rowlen * height), 1)))
    return 0;

  world->array  = world->mem;
  world->width  = width;
  world->height = height;

  for(i = 0; i < height; i++) {
    world->array[i] = world->mem + base + (i * rowlen);
  }

  for(i = 0; i < height; i++) {
    for(j = 0; j < width; j++) {
      if(j != 0) {
        (world->array[i][j]).neighbours[3] = &(world->array[i][j - 1]);
      }

      if(i != 0) {
        (world->array[i][j]).neighbours[1] = &(world->array[i - 1][j]);
      }

      if(j != (width - 1)) {
        (world->array[i][j]).neighbours[4] = &(world->array[i][j + 1]);
      }

      if(i != (height - 1)) {
        (world->array[i][j]).neighbours[6] = &(world->array[i + 1][j]);
      }

      if((i != 0) && (j != 0)) {
        (world->array[i][j]).neighbours[0] = &(world->array[i - 1][j - 1]);
      }

      if((i != (height - 1)) && (j != (width - 1))) {
        (world->array[i][j]).neighbours[7] = &(world->array[i + 1][j + 1]);
      }

      if((i != (height - 1)) && (j != 0)) {
        (world->array[i][j]).neighbours[5] = &(world->array[i + 1][j - 1]);
      }

      if((i != 0) && (j != (width - 1))) {
        (world->array[i][j]).neighbours[2] = &(world->array[i - 1][j + 1]);
      }
    }
  }

  return 1;
}

int main(int argc, char *argv[]) {
  world_t gameoflife;

  if(createworld(&gameoflife, 79, 24)) {
    randomizeworld(&gameoflife);
    do {
      printworld(&gameoflife, stdout);
      getchar();
      fflush(stdin);
      system("clear");
      updateworld(&gameoflife);
    } while(1);
    destroyworld(&gameoflife);
  }

  return 0;
}
