# RegionExport
A utility to export Minetest regions into YAML file.

```
Region Export Utility:
  /re: print this help message;
  /re <|+df|> <|-df|> <|+dy|> <|-dy|> <name>: export a region roughly specified by forward view distance <+df>, 
      backward view distance <-df>, above distance <+dy> and below distance <-dy> into a file named "<name>.re"
      into folder <world>/regions; Put absolute values and don't use negative sign
  /re <x1> <y1> <z1> <x2> <y2> <z2> <name>: export a region precisely specified by two end nodes (inclusive) 
      positions into a file named "<name>.re" into folder <world>/regions
For example:
  - To export (roughly) a 10x10x10 (11x11x11) region around you into a file named "r1.re", 
      issue command: `/re 5 5 5 5 r1`
  - To export (precisely) a 10x10x10 region around you (assume location x0,y0,z0) into a file named "r1.re", 
      issue command: `/re (x0-4) (y0-4) (z0-4) (x1+5) (y1+5) (z1+5) r1`
Notice:
  - No space is allowed in file name.
  - Exported ".re" file is a ".yaml" file and can be opened with text editor
```
