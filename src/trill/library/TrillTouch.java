package trill.library;

import static processing.core.PApplet.*;

public class TrillTouch {
	float scale = 0.25f;
	String color = "00ffccFF";
	float [] size = { 0.0f, 0.0f };
	float [] location = { 0.0f, 0.0f };
	boolean active = false;

	public TrillTouch(float scale, String touchColor, float [] size, float [] location, boolean active) {
		this.scale = scale;
		this.setSize(size);
		this.setLocation(location);
		this.active = active;
		this.color = touchColor;
	} 

	public TrillTouch(float scale, String touchColor, float [] size, float [] location ) {
		this(scale, touchColor, size, location, false);
	}

	public void update(float [] location, float [] size) {
		this.active = true;
		this.setLocation(location);
		this.size[0] = constrain(size[0], 0.0f, 1.0f);
		this.size[1] = constrain(size[1], 0.0f, 1.0f);

	}
	
	public void setSize(float [] size) {
		if(size.length != 2)
			throw new IllegalArgumentException("Size should be specified in 2D.");
		for(int i = 0; i < this.size.length; i++) {
			 this.size[i] = size[i];
		}
	}

	public void setLocation(float [] location) {
		if(location.length != 2)
			throw new IllegalArgumentException("Location should be specified as coordinates in a 2D space.");
		for(int i = 0; i < this.location.length; i++) {
			 this.location[i] = location[i];
		}
	}

	public void changeColor(String newColor) { this.color = newColor; }

	public void changeScale(float scale) {
		if(scale <= 1.0 ) {
			this.scale = scale;
		}
	}

	public boolean isActive() { return this.active; }
}
