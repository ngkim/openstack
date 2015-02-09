#!/bin/bash

BR_GREEN="qbr765d9faf-ec"
BR_ORANGE="qbr204b217f-7f"

echo "========== GREEN Bridge"
brctl showstp $BR_GREEN
echo ""
echo "========== ORANGE Bridge"
brctl showstp $BR_ORANGE

