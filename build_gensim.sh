
#!/bin/bash
set -e

# Manylinux, openblas version, lex_ver
source /io/common_vars.sh

if [ -z "$GENSIM_VERSIONS" ]; then
    GENSIM_VERSIONS="0.12.3"
fi

source /io/library_builders.sh
build_jpeg
build_freetype

# Directory to store wheels
rm_mkdir unfixed_wheels

# Compile wheels
for PYTHON in ${PYTHON_VERSIONS}; do
    PIP="$(cpython_path $PYTHON)/bin/pip"
    for GENSIM in ${GENSIM_VERSIONS}; do
        echo "Building gensim $GENSIM for Python $PYTHON"
        # Put numpy and scipy into the wheelhouse to avoid rebuilding
        $PIP wheel -f $WHEELHOUSE -f $MANYLINUX_URL -w tmp 
        $PIP install -f tmp 
        # Add numpy and scipy  to requirements to avoid upgrading
        $PIP wheel -f tmp -w unfixed_wheels \
            --no-binary gensim \
            "gensim==$GENSIM"
    done
done

# Bundle external shared libraries into the wheels
repair_wheelhouse unfixed_wheels $WHEELHOUSE
