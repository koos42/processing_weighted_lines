import processing.video.*; 

color EDGE_THRESHOLD = 50;
float GAIN = 110.0;

int h;
int w;
double d;
color[][] srcWeights;
color[][] edgeMap;
int mouseX0, mouseY0;
Capture capture;
PImage edgeImage;


void setup() {
  //setupLinework();

  println(Capture.list());
  //println("Paths Loaded: " + lineworkPaths.size());

  h = 300; w = 400; d = .2;
  size(w, h);

  capture = new Capture(this, width, height, Capture.list()[2], 30);
  PImage lineImage = loadImage("/Users/kkleven/desktop/fingerprint1.jpeg");

  capture.read();
  setupWeights(capture);
  setupEdgeMap(lineImage);
  //setupEdgeMap(edgeImage);

  background(255);
  smooth();
  fill(0);
  stroke(0xFF000000);
  image(edgeImage, 0, 0);

}

void draw() {
  capture.read();
  PImage img = capture;
  setupWeights(img);
  
  fill(255);
  //rect(0,0,w,h);
  fill(0);
  
  //weightedEdges(3);
  //diagonalLines(7);
  
}


// STYLES

color[][] getWeights(PImage img, double density) {
  color[][] toRet = new color[(int)(width*density)][(int)(height*density)];
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      toRet[(int)(x*density)][(int)(y*density)] = img.pixels[y*width + x];
    }
  }
  return toRet;
}

void weightedBlackDot(int x, int y){
  float weight = (255 - grey(getWeight(x,y)))/GAIN;

  noStroke();

  fill(0);
  ellipse(x, y, weight, weight);
}

void weightedCurve(int x, int y){
  float weight = (255 - grey(getWeight(x,y)))/GAIN;
  strokeWeight(weight);
  stroke(0);
  noFill();
}

void weightedLine(int x1, int y1, int x2, int y2){
  float weight = (255 - grey(getWeight(x1,y1)))/GAIN;
  strokeWeight(weight);
  stroke(0);
  noFill();
  line(x1,y1,x2,y2);
}

void dotGrid(){
  for (int x = 0; x < srcWeights.length; x++) {
    for (int y = 0; y < srcWeights[x].length; y++) {
      weightedBlackDot((int)(x/d),(int)(y/d));
    }
  }
}

void diagonalLines(int spacing){
  for (int x = spacing; x < w; x+=spacing) {
    for (int y = spacing; y < h; y+=spacing) {
      weightedLine(x-spacing,y-spacing,x,y);
    }
  }
}

void horizontalLines(int spacing){
  for (int x = spacing; x < w; x+=spacing) {
    for (int y = spacing; y < h; y+=spacing) {
      weightedLine(x-spacing,y,x,y);
    }
  }
}

void verticalLines(int spacing){
  for (int x = spacing; x < w; x+=spacing) {
    for (int y = spacing; y < h; y+=spacing) {
      weightedLine(x,y-spacing,x,y);
    }
  }
}

void weightedEdges(int spacing){
  for(int i = 0; i < min(edgeMap.length, width) - spacing; i+=spacing){
    for(int j = 0; j< min(edgeMap[i].length, height) - spacing; j+=spacing){
      if(grey(edgeMap[i][j]) <= EDGE_THRESHOLD){
//        weightedBlackDot(i,j);
        if(grey(edgeMap[i+spacing][j]) <= EDGE_THRESHOLD){
          weightedLine(i,j,i+spacing,j);
        }
        if(grey(edgeMap[i+spacing][j+spacing]) <= EDGE_THRESHOLD){
          weightedLine(i,j,i+spacing,j+spacing);
        }
        if(grey(edgeMap[i][j+spacing]) <= EDGE_THRESHOLD){
          weightedLine(i,j,i,j+spacing);
        }
      }
    }
  }
}

// HELPERS
color grey(color c){
  return (int)(.30 * red(c) + .59 * green(c) + .11 * blue(c));
}

color getWeight(int x, int y){
  capture.read();
  int sampleX = (int)(x * d);
  int sampleY = (int)(y * d);
  return srcWeights[sampleX][sampleY];
}

void setupWeights(PImage img){
  img.loadPixels();
  //load a 2d Array of numbers to serve as weight for the lines.
  srcWeights = getWeights(img, d);
}


/*
 *  For trying to do edge detection, and turning it into lines...
 */
void setupEdgeMap(PImage lineImage){
  edgeImage = createImage(lineImage.width, lineImage.height, RGB);
  lineImage.loadPixels();
  edgeMap = new color[lineImage.width][lineImage.height];
  float[][] edgeFinder = {{-1.0,-1.0,-1.0},{-1.0,9.0,-1.0},{-1.0,-1.0,-1.0}};
  for(int i = 1; i < lineImage.width - 2; i++){
    for(int j = 1; j < lineImage.height - 2; j++){
      float sum = 0;
      for(int ki = -1; ki <=1; ki++){
        for(int kj = -1; kj <= 1; kj++){
          int lineImagePos = (j + kj)*lineImage.width + i + ki;
          float val = lineImage.pixels[lineImagePos];
          sum += edgeFinder[ki+1][kj+1] * val;
        }
      }
      edgeMap[i][j] = color(255 - sum);
      edgeImage.pixels[j*lineImage.width + i] = color(255 - sum);
      print(color(sum));
    }
  }
  edgeImage.updatePixels();
}



