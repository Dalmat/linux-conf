#!/usr/bin/env python
import os,sys,subprocess, pdb, re

def sizeSort(x, y):
	diff = len(y) - len(x)
	if diff != 0:
		return diff
	else:
		return cmp(y, x)

if __name__ == '__main__':
  
  find = subprocess.Popen("/usr/bin/find . -type l", stdout = subprocess.PIPE, shell = True)  
  for line in find.stdout:
    file = line.strip()
    
    # Dangling symlinks
    if not os.path.exists(file):    
      target = os.readlink(file)
      if target.startswith("/srv/ftp"):
	target = target.replace("/srv/ftp", "/mnt/ftp")            
      
      if not os.path.exists(target):
	# Find new location, yes we can !
	destFileName = os.path.basename(target)
	token = None
	# Depending on file to resolve, use different search patterns
	if '-' in destFileName:
	  token = destFileName.split('-')[-1].strip()
	elif not '.' in destFileName:
	  token = destFileName
	  
	if token:
	  fullDir = os.path.abspath(os.path.dirname(os.path.join(os.getcwd(),file)))
	  
	  #tokens = token.split(' ')
	  #cmd = "/usr/bin/locate -i %s" % tokens[0]
	  cmd = "/usr/bin/locate -i %s" % token
	  
	  #if len(tokens) > 1:	    
	    # Avoid doing a locate on an uninteresting pattern (a/the/of, ...)
	  #  tokens.sort(sizeSort)  
	  
	  #  for nextToken in tokens[1:]:
	  #    cmd += " | grep -i %s" % nextToken
	  
	  locate = subprocess.Popen(cmd, stdout = subprocess.PIPE, shell = True)
	  possiblePaths = []
	  matchingRegExp = re.compile(token, re.IGNORECASE)	  
	  for path in locate.stdout:
	    if not fullDir in path:
	      path = path.strip()
	      finalName = path.split('/')[-1]
	      if matchingRegExp.search(finalName): # Filter out patterns in base dir names
		  if '.' in token:
		    if'.' in finalName:
		      possiblePaths.append(path)
		  elif not '.' in finalName:
		    possiblePaths.append(path)
	  
	  if len(possiblePaths) == 0:
	    # Try to do it by token in case of spaces changes
	    #tokens = token.split(' ')
	    #cmd = "/usr/bin/locate -i %s" % tokens[0]
	    cmd = "/usr/bin/locate -i %s" % token
	  
	    #if len(tokens) > 1:	    
	      # Avoid doing a locate on an uninteresting pattern (a/the/of, ...)
	    #  tokens.sort(sizeSort)  
	  
	    #  for nextToken in tokens[1:]:
	    #    cmd += " | grep -i %s" % nextToken
	  
	  if len(possiblePaths) == 1:
	    target = possiblePaths[0]
	  elif len(possiblePaths) > 1:
	    print "Fulldir was %s" % fullDir
	    sys.stdout.write("\nMultiple new targets for %s, please choose:\n" % file)
	    for i, path in enumerate(possiblePaths):
	      sys.stdout.write("%i) [%s]\n" % (i, path))
	    choice = raw_input().lower()
	    try:
	      if 0<=int(choice) < len(possiblePaths):
		target = possiblePaths[int(choice)]
		print "Choosing %s" % target
	    except:
	      pass
	  
	
	if not os.path.exists(target):
	  print "Unknown filepath %s for %s" % (target, file)
	  continue      
      
      newtarget = os.path.relpath(target, os.path.dirname(file))      
      print "%s -> %s" % (file, newtarget)
      
      os.remove(file)
      os.symlink(newtarget, file) 
      
    else:
      pass
    
  