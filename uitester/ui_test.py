from uiautomator import Device
import time
import xml.etree.ElementTree as ET

# Page clickable items
click_items = {}

# Page click item
curr_click = {}

# Pages visit stack
page_stack = []

# Click action for page transition
action = {}

MAX_PAGE_VISIT = 4 
PG_LOAD_TIME = 8

def genSignature():
   d.dump("tmp.xml")
   tree = ET.parse('tmp.xml')
   root = tree.getroot()
   captureItems(root, "", [], 0)
   click_items[ui_rid] = []
   if len(click_list) > 0:
      inner_list = range(0, len(click_list))
      prev_depth = int(click_list[0].split('^')[5])
      prev_id = 0
      for i in range(1, len(click_list)):
          if (int(click_list[i].split('^')[5]) > prev_depth and click_list[i].split('^')[3] == "true" and click_list[i].split('^')[4] == "true") or click_list[prev_id].split('^')[3] == "false" or click_list[prev_id].split('^')[4] == "false":
             inner_list.remove(prev_id)
          prev_depth = int(click_list[i].split('^')[5])
          prev_id = i
      if click_list[prev_id].split('^')[3] == "false" or click_list[prev_id].split('^')[4] == "false":
          inner_list.remove(prev_id)
      sort_click_list = {}
      for i in range(0, len(inner_list)):
          val = click_list[inner_list[i]].split('^')[5]
          key = "%s^%s^%s^%s" %(click_list[inner_list[i]].split('^')[0], click_list[inner_list[i]].split('^')[1], click_list[inner_list[i]].split('^')[2], val)
          if '-' not in click_list[inner_list[i]].split('^')[2]:
             sort_click_list[key] = int(val)
      sort_click_list = sorted(sort_click_list, key=sort_click_list.__getitem__, reverse=True)
      for key in sort_click_list:
          click_items[ui_rid].append(key)
#   print click_items[ui_rid]
   return ui_rid


def captureItems(root, rid_seq, curr_list, depth):
   global ui_rid
   global click_list
   ui_rid = rid_seq
   click_list = curr_list
   for child in root:
       rid = child.get('resource-id')
       text = child.get('text')
       is_clickable = child.get('clickable')
       is_enable = child.get('enabled')
       bound = child.get('bounds')
       if is_enable == "true" and is_clickable == "true":
          ui_rid = ui_rid + "," + rid + "^" + text + "^" + bound
       click_list.append(rid + "^" + text + "^" + bound + "^" + is_enable + "^" + is_clickable + "^" + str(depth))
       captureItems(child, ui_rid, click_list, depth+1)


def getClickableItems():
   if len(page_stack) > 0 and len(page_stack) < MAX_PAGE_VISIT:
      pageID = page_stack[-1]
      s = len(click_items[pageID]) / 3
      print "pageID: %s   %d %d %d" % (pageID, curr_click[pageID], s, len(page_stack))
      for i in range(curr_click[pageID], s):
          print "State: %d %d %d" % (i, s, len(page_stack))
          rid = click_items[pageID][i].split('^')[0]
          text = click_items[pageID][i].split('^')[1]
          bound = click_items[pageID][i].split('^')[2].replace("[", "").replace("]", ",").split(',')
          print "To click: %s %s %s" % (rid, text, click_items[pageID][i].split('^')[2])
          if not d(resourceId=rid).exists:
             print "Cannot find %s" % click_items[pageID][i]
             continue #d.press.back()
                      #time.sleep(4)
          x = (int(bound[0])+int(bound[2])) / 2
          y = (int(bound[1])+int(bound[3])) / 2
          d.click(x, y)
          # Update next click items on pageID
          curr_click[pageID] = curr_click[pageID] + 1
          print "Clicked: %s %s %d %d %s" % (rid, text, x, y, time.time())
          # Wait for new page to load
          time.sleep(PG_LOAD_TIME)
          curr_root = genSignature()
          # Jump from page pageID to curr_root
          action[pageID+"^"+curr_root] = "%d^%d" % (x, y)  #rid + "^" + text
          if curr_root in page_stack:
             while page_stack[-1] != curr_root:
                if curr_root+"^"+page_stack[-1] in action:
                   break
                else:
                   print "Get previous state"
                   page_stack.pop()
             print len(page_stack)
             # Cannot backtrack through clicking some buttons
             if page_stack[-1] == curr_root:
                #d.press.back()
                #time.sleep(4)
                print "Cannot return"
                #page_stack.pop()
             else:
                prid = action[curr_root+"^"+page_stack[-1]].split('^')[0]
                ptext = action[curr_root+"^"+page_stack[-1]].split('^')[1]
                d.click(int(prid), int(ptext))  #d(resourceId=prid, text=ptext).click()
                time.sleep(PG_LOAD_TIME)
                print "Return to " + page_stack[-1]
          elif curr_root in curr_click:
             if curr_click[curr_root] == len(click_items[curr_root]):
                # curr_root is a fully explored page or a shared page from different parents
                '''
                if curr_root+"^"+pageID in action:
                   prid = action[curr_root+"^"+pageID].split('^')[0]
                   ptext = action[curr_root+"^"+pageID].split('^')[1]
                   d.click(int(prid), int(ptext)) #d(resourceId=prid, text=ptext).click()
                   time.sleep(PG_LOAD_TIME)
                else:
                   d.press.back()
                   time.sleep(4)
                getClickableItems()
                '''
                curr_click[curr_root] = 0
                print "Add page"
                page_stack.append(curr_root)
             else:
                print "Add page"
                page_stack.append(curr_root)
          else:
             # curr_root is a new page
             curr_click[curr_root] = 0
             print "Add page"
             page_stack.append(curr_root)
          print "Further explore"
          getClickableItems()
          page_stack.pop()
          d.press.back()
          time.sleep(4)
          print "Backtrack"
   else:
      print "Stop exploring with page stack %d" % len(page_stack)


d = Device('ZX1G22F6V5')
d.screen.on()

root = genSignature()
page_stack.append(root)
curr_click[root] = 0
getClickableItems()
