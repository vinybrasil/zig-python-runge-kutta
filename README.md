# Optimizing Python with Zig for numerical calculations

This is a repository of the blog post [optimizing Python with Zig for numerical calculations with an example using of the 4th Runge Kutta algorithm](vinybrasil.github.io/posts/zig-python-runge-kutta). 

## To build the .so file

```
cd zigfinal && zig build-lib src/main.zig -dynamic -Doptimize=ReleaseFast
```

## To run it

```
python run.py
```

OBS: Versions used: Python 3.12.3 and Zig 0.14.0