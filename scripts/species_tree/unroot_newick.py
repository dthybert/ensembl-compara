#!/homes/carlac/anaconda_ete/bin/python

# Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
# Copyright [2016-2019] EMBL-European Bioinformatics Institute
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import sys, os
from ete3 import Tree

infile = sys.argv[1]
if not os.path.isfile(infile):
	sys.stderr.write("File %s not found", infile)
	sys.exit(1)

t = Tree(infile)
root = t.get_tree_root()
root.unroot()
print(root.write(format=5))
