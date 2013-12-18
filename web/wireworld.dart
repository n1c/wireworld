import 'dart:async';
import 'dart:html';

class Board {
  static const int CELL_SIZE = 16;
  static ImageElement sheet = new ImageElement(src: 'img/sheet.png');
  int w, h;
  int tickCount = 0;
  List<int> blocks;
  List<int> neighbourCounts;

  Board(this.w, this.h) {
    blocks = new List<int>(w * h);
    blocks.fillRange(0, w * h, 0);

    neighbourCounts = new List<int>(w * h);
    neighbourCounts.fillRange(0, w * h, 0);
  } // Board

  int toggle(int x, int y) {
    if (x < 0 || y < 0 || x >= w || y >= h) return -1;

    blocks[(y * w) + x] = blocks[(y * w) + x] == 0 ? 1 : 0;
    return blocks[(y * w) + x];
  } // toggle

  void set(int x, int y, int val) {
    if (x < 0 || y < 0 || x >= w || y >= h) return;
    blocks[(y * w) + x] = val;
  } // set

  void tick() {
    tickCount = (tickCount + 1) % 6;
    // Origin block
    blocks[w ~/ 2] = 3 - tickCount;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        if (blocks[(y * w) + x] == 3) {
          if (x > 0) neighbourCounts[(x - 1) + y * w]++;
          if (y > 0) neighbourCounts[x + (y - 1) * w]++;
          if (x < w - 1) neighbourCounts[(x + 1) + y * w]++;
          if (y < h - 1) neighbourCounts[x + (y + 1) * w]++;

          // Diagonal corners
          if (x > 0 && y > 0) neighbourCounts[(x - 1) + (y - 1) * w]++;
          if (x > 0 && y < h - 1) neighbourCounts[(x - 1) + (y + 1) * w]++;
          if (x < w - 1 && y > 0) neighbourCounts[(x + 1) + (y - 1) * w]++;
          if (x < w - 1 && y < h - 1) neighbourCounts[(x + 1) + (y + 1) * w]++;
        } // if block = 3
      } // for x < w
    } // for y < h

    for (int i = 0; i < w * h; i++) {
      if (blocks[i] > 1) {
        blocks[i]--;
      } else if (blocks[i] == 1) {
        if (neighbourCounts[i] == 1 || neighbourCounts[i] == 2) {
          blocks[i] = 3;
        } // if blocks
      } // if blocks

      neighbourCounts[i] = 0;
    } // for each block
  } // tick

  void render(CanvasRenderingContext2D c2d) {
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        c2d.drawImageScaledFromSource(
            sheet,
            blocks[(y * w) + x] * 16,
            0,
            16,
            16,
            x * CELL_SIZE,
            y * CELL_SIZE,
            CELL_SIZE,
            CELL_SIZE
        ); // drawImageScaledFromSource
      } // for x < w
    } // for y < h
  } // render

} // Board

class Game {
  CanvasElement canvas;
  CanvasRenderingContext2D c2d;
  Board board;
  int dragging = -1;

  Game(this.canvas) {
    c2d = canvas.getContext('2d');
    board = new Board(32, 32);
    canvas.width = board.w * Board.CELL_SIZE;
    canvas.height = board.h * Board.CELL_SIZE;

    canvas.onMouseDown.listen(onMouseDown);
    canvas.onMouseMove.listen(onMouseMove);
    window.onMouseUp.listen(onMouseUp);

    tick();
  } // Game

  void onMouseDown(MouseEvent e) {
    int xCell = e.offset.x ~/ Board.CELL_SIZE;
    int yCell = e.offset.y ~/ Board.CELL_SIZE;

    dragging = board.toggle(xCell, yCell);
  } // onMouseDown

  void onMouseMove(MouseEvent e) {
    if (dragging >= 0) {
      int xCell = e.offset.x ~/ Board.CELL_SIZE;
      int yCell = e.offset.y ~/ Board.CELL_SIZE;

      board.set(xCell, yCell, dragging);
    } // if dragging
  } // onMouseMove

  void onMouseUp(MouseEvent e) {
    dragging = -1;
  } // onMouseUp

  void tick() {
    board.tick();
    render();
    new Future.delayed(new Duration(milliseconds: 100), tick);
  } // tick

  void render() {
    board.render(c2d);
  } // render
} // Game

void main() {
  new Game(querySelector('#canvas'));
} // main
