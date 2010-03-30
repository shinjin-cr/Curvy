CircleNode root;

CircleNode active = null;
boolean asDeg3 = true;

void setup() {
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
  }}); 

  size(800, 800);
  background(#FEECD1);
  smooth();
  
  frameRate(24);
  
  root = new CircleNode(width/2, height/2, min(width/2, height/2)*0.19, false, null);
//  boolean b = false;
//  for (int i = 0; i < 6; i+=2) {
//    root.addCircle(160+240*cos(-PI/3+i*PI/8), 300+240*sin(-PI/3+i*PI/8), 40+5*i, false);
//    b = !b;
//  }
//  
//  root.getChild(0).addCircle(500, 160, 40, true);
//  root.getChild(1).addCircle(540, 320, 40, true);
  setActive(root);
}

void setActive(CircleNode newactive) {
  if (newactive == active) return;
  if (active != null) active.highlight = false;
  active = newactive;
  if (active != null) active.highlight = true;
}

void draw() {
  background(#FEECD1);
  root.draw(asDeg3);
}

void mousePressed() {
  if (mouseButton == LEFT) {
    if (active != null) active.highlight = false;
    CircleNode newactive = root.findByPoint(new PVector(mouseX, mouseY));
    if (newactive != null) {
      active = newactive;
      active.highlight = true;
    } else if (active != null) {
      active = active.addCircle(mouseX, mouseY, active.r, !active.mirrored);
      active.highlight = true;
    }
  } else if (mouseButton == RIGHT) {
    if (active != null) {
      active.highlight = false;
      active = null;
    }
  }
}

void mouseDragged() {
  if (active != null) {
    active.move(new PVector(mouseX-pmouseX, mouseY-pmouseY));
  }
}

void mouseWheel(int notches) {
  if (active != null) {
    active.setR(active.getR() - notches);
  }  
}

void keyPressed() {
  CircleNode newactive = null, p;
  if (active != null) {
    if (key == ' ') {
      newactive = active.addCircle(active.center.x, active.center.y, active.r*0.75, !active.mirrored);
    } else if (key == 'q') {
      active.changeTheta(0.1);
    } else if (key == 'w') {
      active.changeTheta(-0.1);
    } else if (key == ENTER) {
      println("<SVG>\n"+root.asSVG()+"</SVG>");
    } else if (key == TAB && active != null) {
      active.flip();
    }
  }

  if (key == '3') {
    asDeg3 = !asDeg3;
  }
  if (key == CODED && keyCode == SHIFT) {
    root.drawCircles(false);
  }  else if (active != null) {
    if (keyCode == UP) {
      newactive = active.getParent();
    } else if (keyCode == DOWN) {
      newactive = active.getFirstChild();
    } else if ((p = active.getParent()) != null) {
      if (keyCode == RIGHT) {
        newactive = p.getNextChild(active);
      } else if (keyCode == LEFT) {
        newactive = p.getPrevChild(active);
      }
    }
  }
  if (newactive != null)
    setActive(newactive);
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      root.drawCircles(true);
    }
  } 
}
