# Acorn 


Some possible useful solutions and tips for working with Roots Acorn.

```
getting issues post Acorn package removal? Seeing errors like
```
Skipping provider [Vendor\SageNativeBlockPackage\Providers\SageNativeBlockServiceProvider] because it encountered an error [ErrorException]: include(/srv/www/Vendor.com/current/web/app/themes/nynaeve/vendor/composer/../Vendor/sage-native-block/src/Providers/SageNativeBlockServiceProvider.php): Failed to open stream: No such file or directory
```

or
```wp acorn optimize:clear 
in ClassLoader.php line 571:                                                               
  include(/srv/www/imagewize.com/current/web/app/themes/nynaeve/vendor/composer/../imagewize/sage-native-block/src/Providers/SageNativeBlockServiceProvider.php): Failed to open stream: No such file or directory       

Try 
```
wp acorn optimize
```

