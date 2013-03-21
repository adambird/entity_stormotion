#!/usr/bin/env rake
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require "bundler/gem_tasks"
Bundler.setup
Bundler.require
require 'bubble-wrap/test'
require 'motion-cocoapods'

Motion::Project::App.setup do |app|
  app.name = 'EntityStormotionTest'
  app.identifier = 'com.adambird.entity_stormotion.test'
  app.specs_dir = './spec/motion'
  app.version = EntityStormotion::VERSION
  app.pods do
    dependency 'FMDB'
  end
end