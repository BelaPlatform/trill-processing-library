package trill.library;
import java.util.*;
import java.lang.*;
import processing.core.*;
import static processing.core.PApplet.*;

public class Trill {

	final PApplet parent;

	String type;
	int maxNumTouches = 5;
	int maxTouchLocation = 1792;
	int maxTouchHLocation = 1792;
	int maxTouchSize = 7000;

	float [] dimensions = { 0.0f, 0.0f };
	float cornerRadius = 0;
	float position[] = { 0.0f, 0.0f };
	List<String> types = Arrays.asList("bar", "square", "hex", "ring");
	float touchScale = 0.4f;
	String sensorColor = "FF000000"; // black
	String [] touchColors = { "FFFF0000", "FF0000FF", "FFFFFF00", "FFFFFFFF", "FF00FFFF" }; // red, blue, yellow, white, cyan
	ArrayList<TrillTouch> trillTouches = new ArrayList<TrillTouch>(5);
	int [] touchIndices = { -1, -1 , -1 , -1, -1, -1 , -1, -1, -1 , -1 , -1, -1, -1, -1, -1, -1}; //there will be at most 16 touches (4x4 in Trill square)

	public Trill(PApplet parent, String type, float length, float [] position, float touchScale) {
		this.parent = parent;
		this.type = type.toLowerCase();
		if(!types.contains(this.type)) {
			this.type = "unknown";
			throw new IllegalArgumentException("Unknown Trill type.");
		}
		if (this.type == "bar")
			maxTouchLocation = 3200;
		else if (this.type == "hex") {
			maxTouchLocation = 1920;
			maxTouchHLocation = 1664;
		}
		else if (this.type == "ring")
			maxTouchLocation = 3584;

		resize(length);
		setPosition(position);
		setMaxNumTouches();
		this.touchScale = touchScale;
	}

	public Trill(PApplet parent, String type, float length, float [] position) {
		this(parent, type, length, position, 0.4f);
	}

	void setMaxNumTouches() {
		if(this.is2D()) {
			this.maxNumTouches = 16;
		} else {
			this.maxNumTouches = 5;
		}
	}

	public void changeTouchScale(float touchScale) {
		this.touchScale = touchScale;
		this.trillTouches.forEach(touch -> touch.changeScale(this.touchScale));
	}

	public void setPosition(float [] position) {
		if(position.length != 2)
			throw new IllegalArgumentException("Position should be specified as coordinates in a 2D space.");
		for(int i = 0; i < this.position.length; i++) {
			this.position[i] = position[i];
		}
	}

	public void resize (float length) {

		this.dimensions[0] = length;
		if(this.type == "bar") {
			this.dimensions[1] = length/5;
		} else if(this.type == "hex") {
			this.dimensions[1] = length/0.866f;
		} else {
			this.dimensions[1] = length;
		}

		if(this.type == "bar") {
			this.cornerRadius = 0.03f * this.dimensions[0];
		} else if(this.type == "square") {
			this.cornerRadius = 0.02f * this.dimensions[0];
		} else {
			this.cornerRadius = 0.0f;
		}
	}

	public void updateTouch (int i, float [] location, float [] size) {
		float [] _location = new float[2];
		_location[0] = location[0];
		if(this.is2D()) {
			if(location.length != 2)
				throw new IllegalArgumentException("Location for 2D Trill devices should be specified as coordinates in a 2D space.");
			_location[1] = location[1];
		} else {
			_location[1] = 0.5f;
		}
		if(this.touchIndices[i] == -1) {
			this.trillTouches.add(new TrillTouch(this.touchScale, this.touchColors[i % 5], size, _location));
			this.touchIndices[i] = this.trillTouches.size() - 1;
		} else {
			this.trillTouches.get(touchIndices[i]).update(_location, size);
		}
	}

	public void updateTouch (int i, float location, float size) {
		this.updateTouch(i, new float[]{location, 0.0f}, new float[]{size, size});
	}

	public int activeTouches() {
		int activeTouches = trillTouches.stream()
			.map(t -> t.isActive() ? 1 : 0)
			.mapToInt(t -> t)
			.sum();
		return activeTouches;
	}

	public void draw() {
		parent.fill(unhex(this.sensorColor));
		if (this.type == "bar" || this.type == "square") {
			parent.rectMode(CENTER);
			parent.rect(this.position[0], this.position[1], this.dimensions[0], this.dimensions[1], this.cornerRadius);
		} else if (this.type == "ring") {
			parent.push();
			parent.translate(this.position[0], this.position[1]);
			parent.noFill();
			parent.stroke(unhex(this.sensorColor));
			parent.strokeWeight(this.dimensions[0] * 0.25f);
			parent.ellipse(0,0,this.dimensions[0], this.dimensions[1]);
			parent.pop();
		} else if (this.type == "hex") {
			parent.push();
			// move to the centre of the hex
			parent.translate(this.position[0], this.position[1]);
			// draw the hexagon
			parent.beginShape();
			parent.vertex(0, this.dimensions[1] * -0.5f);
			parent.vertex(this.dimensions[0] * 0.5f, this.dimensions[1] * -0.25f);
			parent.vertex(this.dimensions[0] * 0.5f, this.dimensions[1] * 0.25f);
			parent.vertex(0, this.dimensions[1] * 0.5f);
			parent.vertex(-this.dimensions[0] * 0.5f, this.dimensions[1] * 0.25f);
			parent.vertex(-this.dimensions[0] * 0.5f, this.dimensions[1] * -0.25f);
			parent.endShape(CLOSE);
			parent.pop();
		}
	}

	public void drawTouches() {
		for(TrillTouch touch : this.trillTouches) {
			if(touch.isActive()) {
				this.drawTouch(touch);
				touch.active = false;
			}
		}
	}

	public void drawCompoundTouch() {
		float [] avgLoc = {0.0f ,0.0f};
		float [] avgSize = {0.0f ,0.0f};
		int activeTouches = 0;

		for(TrillTouch touch : this.trillTouches) {
			if(touch.isActive()) {
				avgLoc[0] += touch.getLocation()[0]*touch.getSize()[0];
				avgLoc[1] += touch.getLocation()[1]*touch.getSize()[1];
				avgSize[0] += touch.getSize()[0];
				avgSize[1] += touch.getSize()[1];
				activeTouches++;
				touch.active = false;
			}
		}

		if (activeTouches > 0) {
			avgSize[0] /= (float)activeTouches;
			avgSize[1] /= (float)activeTouches;
			avgSize[0] = 0.5f*(avgSize[0]+avgSize[1]);
			avgSize[1] = 0.5f*(avgSize[0]+avgSize[1]);
			avgLoc[0] /= ((float)activeTouches * avgSize[0]);
			avgLoc[1] /= ((float)activeTouches * avgSize[1]);

			TrillTouch t1 = new TrillTouch(this.touchScale,  "FFFF0000", avgSize, avgLoc);
			drawTouch(t1);
		}
	}

	public void drawTouch(TrillTouch touch) {
		parent.fill(unhex(touch.color));
		float [] diameter = { this.dimensions[0]*touch.size[0]*touch.scale, this.dimensions[0]*touch.size[1]*touch.scale };

		if(this.type == "bar" || this.type == "square") {
			parent.ellipse(this.position[0] - this.dimensions[0] * 0.5f + this.dimensions[0] * touch.location[0], this.position[1] - this.dimensions[1] * 0.5f + this.dimensions[1] * (1 - touch.location[1]), diameter[0], diameter[1]);
		} else if (this.type == "ring") {
			parent.push();
			parent.translate(this.position[0], this.position[1]);
			float _radial = (touch.location[0]) * PI * 2.0f;
			if (_radial >= PI * 2.0f){
				_radial = 0.0f;
			}
			parent.ellipse((this.dimensions[0] * 0.5f) * cos(_radial), (this.dimensions[0] * 0.5f) * sin(_radial), diameter[0], diameter[1]);
			parent.pop();
		} else if (this.type == "hex") {
			parent.ellipse((this.position[0] - this.dimensions[0] * 0.5f) + touch.location[0] * this.dimensions[0], (this.position[1] - this.dimensions[1] * 0.5f) + (1 - touch.location[1]) * this.dimensions[1], diameter[0], diameter[1]);
		}
	}

	public void drawTouch(int i) {
		if(this.touchIndices[i]	 != -1)
			this.drawTouch(this.trillTouches.get(touchIndices[i]));
	}

	public boolean is2D() {
		if(this.type == "square" || this.type == "hex")
			return true;
		else
			return false;
	}

	public void serialParse(String serialString) {
		int touchIndex = serialString.indexOf("T");
		if(touchIndex >= 0) {
			serialString = serialString.substring(touchIndex+1);
		}
		int buttonIndex = serialString.indexOf("B");
		if(buttonIndex != -1) {
			return;
		}
		String inString = trim(serialString);
		int[] values = Arrays.asList(split(inString, " ")).stream().mapToInt(Integer::parseInt).toArray();
		int i;

		if(this.is2D()) {
			if(values.length >= 2) {
				// Look for first two numbers telling us number of H and V touches

				int nTouches = values[0];
				int nHTouches = values[1];
				float [] touchLocation = { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
				float [] touchSize = { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
				float [] touchHLocation = { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
				float [] touchHSize = { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };

				// Vertical touches
				for(i = 0; i < nTouches; i++) {
					if(i >= maxNumTouches)
						break;
					if(i*2 + 3 >= values.length) {
						// Malformed line...
						nTouches = nHTouches = 0;
						break;
					}
					touchLocation[i] = values[2 + i*2]/(float)maxTouchLocation;
					touchSize[i] = values[2 + i*2 + 1]/(float)maxTouchSize;
				}

				// Horizontal touches
				for(i = 0; i < nHTouches; i++) {
					if(i >= maxNumTouches)
						break;
					int j = i + nTouches;
					if(j*2 + 3 >= values.length) {
						// Malformed line...
						nTouches = nHTouches = 0;
						break;
					}
					touchHLocation[i] = values[2 + 2 * j]/(float)maxTouchHLocation;
					touchHSize[i] = values[2 + 2*j + 1]/(float)maxTouchSize;
				}

				// Update touch
				for(i = 0; i < nTouches; i++) {
					for(int j = 0; j < nHTouches; j++) {
						float [] pair = {touchHLocation[j],touchLocation[i]};
						float [] pair2 = {touchHSize[j],touchSize[i]};
						this.updateTouch(i * nHTouches + j, pair, pair2);
					}
				}
			}
		} else {
			for(i = 0; i < values.length - 1; i += 2) {
				if(i/2 >= maxNumTouches)
					break;
				// Update touch
				this.updateTouch(i/2, values[i]/(float)maxTouchLocation, values[i+1]/(float)maxTouchSize);
			}
		}
	}
}
