import java.util.*;

int cellSize = 6;
int cols, rows;
int wallThickness = 5;

HashSet<Integer> walls        = new HashSet<Integer>();
HashSet<Integer> cachedChecks = new HashSet<Integer>();

PVector mouse       = new PVector();  // current mouse position in pixels
PVector cellCenter  = new PVector();  // centre of the tile we draw
PVector cellToMouse = new PVector();  // mouse − centre (re‑used)

float halfCell = cellSize * 0.5f;
boolean wallsIsEmpty;

void setup() {
  size(800, 600);
  cols = floor(width  / cellSize);
  rows = floor(height / cellSize);
}

void mouseDragged() {
  int extent = floor(wallThickness / 2f);

  for (int dx = -extent; dx <= extent; dx++) {
    for (int dy = -extent; dy <= extent; dy++) {
      int col = mouseX / cellSize + dx;
      int row = mouseY / cellSize + dy;
      if (col < 0 || col >= cols || row < 0 || row >= rows) continue;
      walls.add(col + row * cols);
    }
  }
}

void draw() {
  background(25);

  mouse.set(mouseX, mouseY);
  int mx = mouseX / cellSize;   // destination cell (grid coords)
  int my = mouseY / cellSize;

  wallsIsEmpty = walls.isEmpty();
  cachedChecks.clear();
  noStroke();

  for (int col = 0; col < cols; col++) {
    float cxPix = col * cellSize + halfCell;

    for (int row = 0; row < rows; row++) {
      int index = col + row * cols;

      // distance based shading
      cellCenter.set(cxPix, row * cellSize + halfCell);
      cellToMouse.set(mouse).sub(cellCenter);
      float shade = 255 - cellToMouse.mag();

      // occlusion test
      if (Raycast(col, row, mx, my)) shade = 0;

      // draw cell
      if (CellIsWall(index)) {
        fill(255, 35, 15);
      } else {
        fill(shade);
      }
      square(col * cellSize, row * cellSize, cellSize);
    }
  }
  fill(255);
  text(frameRate, 30, 30);
}

boolean CellIsWall(int index) {
  return walls.contains(index);
}

// Bresenham's line algorithm (with some caching)
boolean Raycast(int x0, int y0, int x1, int y1) {
  if (wallsIsEmpty) return false;

  int dx = abs(x1 - x0);
  int sx = x0 < x1 ? 1 : -1;
  int dy = -abs(y1 - y0);
  int sy = y0 < y1 ? 1 : -1;
  int err = dx + dy;

  int srcIdx = x0 + y0 * cols;
  if (cachedChecks.contains(srcIdx)) return true;

  while (true) {
    int idx = x0 + y0 * cols;
    if (walls.contains(idx)) {
      cachedChecks.add(srcIdx);
      return true;
    }
    if (x0 == x1 && y0 == y1) break;

    int e2 = 2 * err;
    if (e2 >= dy) {
      err += dy;
      x0  += sx;
    }
    if (e2 <= dx) {
      err += dx;
      y0  += sy;
    }
  }
  return false; // clear path
}
