# ID3 or 'Iterative Dichotomizer 3' is and algorithm for creating
# a decision tree from a dataset. It is fairly simple, and we will
# use this as an introduction to decision tree learning.

# NOTE: We will limit our implementation to categorical/factor variables
#		This is to keep the clarity and simplicity of this 
#		intellectual exercise. It can be easily extended to deal with
# 		continuous variables by implementing a discretization method
#		for continuous variables. A popular method is k-means classification.

# First, while not strictly necessary, we will create two R class types:
# Tree and Node for easier handling of the tree-structure.

# Tree:
# Tree will be used in a recursive structure that contians a either
# another tree or a node at each branch. Notice that we use a list
# for the branches, so that each tree can contain an arbitrary number
# of brances.
tree <- function(root, branches) {
  structure(list(root=root, branches=branches), class='tree')
}

# Node:
# Node is the used for the terminal location in the trees. Each branch
# that contains a node will signify that the algorithm has either:
# 	1. Every element in the subset belongs to the same class
#	2. There are no more attributes to be selected
#	3. There are no more examples in the subset
node <- function(root) {
  structure(list(root=as.character(root)), class='node')
}

# Entropy: H(S) - a measure of uncertainty in the set S
# H(S) = - sum(p(x) * log2(p(x)) for each subset x of S
entropy <- function(S) {
  if (!is.factor(S)) S <- as.factor(S)
  
  p <- prop.table(table(S))
  
  -sum(sapply(levels(S),
              function(name) p[name] * log2(p[name]))
  )
}

# ID3: 	The meat of the algorithm
#		Recursively builds a tree data structure that contians the 
#		decision tree
# Note: In order for this implementation to work, all variables in 
#		the data frame must be factors!
ID3 <- function(dataset, target_attr,
                attributes=setdiff(names(dataset), target_attr)) {
  # If there are no attributes left to classify with,
  # return the most common class left in the dataset
  # as a best approximation.
  if (length(attributes) <= 0) {
    # DEBUG: print("attributes ran out")
    return(node(most.frq(dataset[, target_attr])))
  }
  
  # If there is only one classification left, return a
  # node with that classification as the answer
  if (length(unique(dataset[, target_attr])) == 1) {
    # DEBUG: print('one class left')
    return(node(unique(dataset[, target_attr])[1]))
  }
  
  # Select the best attribute based on the minimum entropy
  best_attr <- attributes[which.min(sapply(attributes, entropy))]
  # Create the set of remaining attributes
  rem_attrs <- setdiff(attributes, best_attr)
  # Split the dataset into groups based on levels of the best_attr
  split_dataset <- split(dataset, dataset[, best_attr])
  # Recursively branch to create the tree.
  branches <- lapply(seq_along(split_dataset), function(i) {
    # The name of the branch
    name <- names(split_dataset)[i]
    # Get branch data
    branch <- split_dataset[[i]]
    
    # If there is no data, return the most frequent class in
    # the parent, otherwise start over with new branch data.
    if (nrow(branch) == 0) node(most.frq(dataset[, target_attr]))
    else ID3(branch[, union(target_attr, rem_attrs), drop=FALSE],
             target_attr,
             rem_attrs)
  })
  names(branches) <- names(split_dataset)
  
  id3_tree <- tree(root=best_attr, branches=branches)
  id3_tree
}

# The prediciton method:
# This algorithm isn't really useful if we don't have a way to utilize it.
# This function takes a tree object created from ID3, and traverses it for
# each item in the test_obs data frame. The classifications for each item
# is returned.
predict_ID3 <- function(test_obs, id3_tree) {
  traverse <- function(obs, work_tree) {
    if (class(work_tree) == 'node') work_tree$root
    else {
      var <- work_tree$root
      new_tree <- work_tree$branches[[as.character(obs[var])]]
      traverse(obs, new_tree)
    }
  }
  apply(test_obs, 1, traverse, work_tree=id3_tree)
}