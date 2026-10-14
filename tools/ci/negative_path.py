"""Prove real validators reject corrupt packages and zero-exit assertion failures."""
import struct
from package import audit_pack
from qa import hard_errors
assert hard_errors('FAIL: deliberately injected validation failure')
assert hard_errors('SCRIPT ERROR: deliberately injected parser failure')
assert hard_errors('ERROR: Failed loading resource')
try:
    audit_pack(b'corrupt package')
except AssertionError:
    print('PASS: corrupt package rejected')
else:
    raise AssertionError('Corrupt package accepted')
print('PASS: zero-exit assertion/parser/load errors rejected')
