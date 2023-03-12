#! /bin/bash
#find scripts/ -name '*.ttslua' -exec sed -i 's/constants\.pass_turn_anchors\[\([^]]*\)\]/constants.players[\1].pass_turn_anchors/g' {} \;
#find scripts/ -name '*.ttslua' -exec sed -i 's/pass_turn_anchors\[\([^]]*\)\]/constants.players[\1].pass_turn_anchors/g' {} \;
find scripts/ -name '*.ttslua' -exec sed -i 's/constants\.helperModule/helperModule/g' {} \;
