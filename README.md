# AZASScroll

The scroll content, data list, data select component for AS3.

## Features:

- iOS UIScrollView/UITableView like APIs.
- Full functional scroll/list/select features for arbitrary data.
- Pure core AS3 lib implementation, no Flex or other 3rd party lib.

## Classes

### ScrollView

The base class for other two. For displaying large content that overflow current visiable area. User can drag and scroll to see the full content.

- Bounce effect when interactive.
- Inertial drag and move.
- Paged scroll.

### ListView

For displaying the same kind large objects set in a list.

- Variable height for different rows.
- Different styles for different rows.
- With Header and Footer views.
- After creating, rows cached and resued, so the performance is excellent.

### SelectView

For displaying and selecting objects.

- Single or multiple selection.
- Build-in limited total selection count.

---
_See the demo project for the usage_
